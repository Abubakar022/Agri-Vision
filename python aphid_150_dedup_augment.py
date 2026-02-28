import argparse, random, json, shutil
from pathlib import Path
from collections import defaultdict
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

IMG_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
DEFAULT_DATASET = r"C:\Users\lenovo t480s\Desktop\wheat diseases"  # fallback

def is_image(p: Path) -> bool:
    return p.suffix.lower() in IMG_EXTS

def list_classes(root: Path):
    classes = [d for d in root.iterdir() if d.is_dir() and not d.name.startswith(".")]
    classes.sort(key=lambda x: x.name.lower())
    return classes

def list_images(folder: Path):
    imgs = [p for p in folder.iterdir() if p.is_file() and is_image(p)]
    imgs.sort(key=lambda x: x.name.lower())
    return imgs

# ---------- pHash (needs numpy) ----------
def phash(img: Image.Image, hash_size=8, highfreq_factor=4) -> int:
    import numpy as np
    img = img.convert("L")
    size = hash_size * highfreq_factor
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    x = np.asarray(img, dtype=np.float32)

    N = size
    n = np.arange(N)
    k = n.reshape((N, 1))
    dct_mat = np.cos((3.141592653589793 / N) * (n + 0.5) * k)
    dct_mat[0, :] *= 1.0 / (2 ** 0.5)
    dct_mat *= (2 / N) ** 0.5
    dct = dct_mat @ x @ dct_mat.T

    d = dct[:hash_size, :hash_size].flatten()
    med = float(np.median(d[1:]))  # exclude DC
    bits = (dct[:hash_size, :hash_size] > med).flatten()

    h = 0
    for b in bits:
        h = (h << 1) | int(bool(b))
    return int(h)

def hamming(a: int, b: int) -> int:
    return (a ^ b).bit_count()

def dedup_in_class(cls_dir: Path, threshold: int):
    imgs = list_images(cls_dir)
    hashes = []
    removed = 0
    for p in imgs:
        try:
            with Image.open(p) as im:
                im = ImageOps.exif_transpose(im)
                h = phash(im)
        except Exception:
            try: p.unlink()
            except: pass
            removed += 1
            continue

        if any(hamming(h, old) <= threshold for old in hashes):
            try: p.unlink()
            except: pass
            removed += 1
        else:
            hashes.append(h)
    return removed

# ---------- augmentation ----------
def augment_pil(img: Image.Image) -> Image.Image:
    img = img.convert("RGB")

    if random.random() < 0.5:
        img = ImageOps.mirror(img)

    if random.random() < 0.6:
        angle = random.uniform(-12, 12)
        img = img.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)

    if random.random() < 0.7:
        w, h = img.size
        scale = random.uniform(0.70, 1.0)
        nw, nh = int(w * scale), int(h * scale)
        if nw > 20 and nh > 20:
            left = random.randint(0, max(0, w - nw))
            top  = random.randint(0, max(0, h - nh))
            img = img.crop((left, top, left + nw, top + nh)).resize((w, h), Image.Resampling.LANCZOS)

    if random.random() < 0.85:
        img = ImageEnhance.Brightness(img).enhance(random.uniform(0.85, 1.2))
        img = ImageEnhance.Contrast(img).enhance(random.uniform(0.85, 1.2))
        img = ImageEnhance.Color(img).enhance(random.uniform(0.85, 1.2))

    if random.random() < 0.15:
        img = img.filter(ImageFilter.GaussianBlur(radius=random.uniform(0.2, 1.0)))

    return img

def trim_to_target(cls_dir: Path, target: int):
    imgs = list_images(cls_dir)
    if len(imgs) <= target:
        return 0
    random.shuffle(imgs)
    to_remove = imgs[target:]
    for p in to_remove:
        try: p.unlink()
        except: pass
    return len(to_remove)

def augment_to_target(cls_dir: Path, target: int, copies_cap_per_image: int):
    cur_imgs = list_images(cls_dir)
    if len(cur_imgs) == 0 or len(cur_imgs) >= target:
        return 0

    per_src = defaultdict(int)
    created = 0
    needed = target - len(cur_imgs)

    safety = 0
    max_safety = needed * 200

    while len(list_images(cls_dir)) < target and safety < max_safety:
        safety += 1
        imgs = list_images(cls_dir)
        if len(imgs) >= target:
            break

        src = random.choice(imgs)
        if per_src[str(src)] >= copies_cap_per_image:
            continue

        try:
            with Image.open(src) as im:
                im = ImageOps.exif_transpose(im)
                aug = augment_pil(im)
        except Exception:
            continue

        out_name = f"{src.stem}__aug_{per_src[str(src)]:03d}{src.suffix.lower()}"
        out_path = cls_dir / out_name
        if out_path.exists():
            per_src[str(src)] += 1
            continue

        aug.save(out_path, quality=95)
        per_src[str(src)] += 1
        created += 1

    return created

def copy_dataset(src_root: Path, out_root: Path, overwrite: bool):
    if out_root.exists():
        if overwrite:
            shutil.rmtree(out_root)
        else:
            raise SystemExit(f"ERROR: Output exists: {out_root}\nRun with --overwrite")

    out_root.mkdir(parents=True, exist_ok=True)
    for cls_dir in list_classes(src_root):
        dst_cls = out_root / cls_dir.name
        dst_cls.mkdir(parents=True, exist_ok=True)
        for p in list_images(cls_dir):
            shutil.copy2(p, dst_cls / p.name)

def count_per_class(root: Path):
    return {c.name: len(list_images(c)) for c in list_classes(root)}

def main():
    ap = argparse.ArgumentParser(description="Dedup + Balance all classes to EXACT target images (handles all run styles)")
    ap.add_argument("dataset", nargs="?", help="Dataset root path (positional)")
    ap.add_argument("--input", help="Dataset root path (flag)")
    ap.add_argument("--target", type=int, default=150)
    ap.add_argument("--dedup_threshold", type=int, default=6)
    ap.add_argument("--copies_cap_per_image", type=int, default=10)
    ap.add_argument("--overwrite", action="store_true")
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    random.seed(args.seed)

    dataset_path = args.input or args.dataset or DEFAULT_DATASET
    src_root = Path(dataset_path).expanduser().resolve()

    if not src_root.exists():
        raise SystemExit(f"ERROR: Dataset not found: {src_root}\nProvide path like:\n  python script.py \"C:\\Users\\...\\wheat diseases\"")

    out_root = src_root.parent / f"{src_root.name}_balanced_{args.target}"
    print("✅ INPUT :", src_root)
    print("✅ OUTPUT:", out_root)

    copy_dataset(src_root, out_root, overwrite=args.overwrite)

    report = {
        "input": str(src_root),
        "output": str(out_root),
        "target": args.target,
        "before_counts": count_per_class(out_root),
        "per_class": {},
        "after_counts": None
    }

    for cls_dir in list_classes(out_root):
        cls = cls_dir.name

        dup_removed = dedup_in_class(cls_dir, args.dedup_threshold)

        trim1 = trim_to_target(cls_dir, args.target)
        aug_added = augment_to_target(cls_dir, args.target, args.copies_cap_per_image)

        # FINAL HARD CAP -> guarantees EXACT <= target
        trim2 = trim_to_target(cls_dir, args.target)

        final = len(list_images(cls_dir))
        report["per_class"][cls] = {
            "dup_removed": dup_removed,
            "trim_before_aug": trim1,
            "aug_added": aug_added,
            "final_trim": trim2,
            "final": final
        }

        print(f"✅ {cls}: FINAL={final} (dup_rm={dup_removed}, trim1={trim1}, aug={aug_added}, trim2={trim2})")

    report["after_counts"] = count_per_class(out_root)

    with open(out_root / "report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("\n✅ DONE")
    print("Saved to:", out_root)
    print("Final counts:", report["after_counts"])
    print("Report:", out_root / "report.json")

if __name__ == "__main__":
    main()