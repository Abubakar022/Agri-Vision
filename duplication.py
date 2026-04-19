# save as: aphid_150_dedup_augment.py
# ✅ Does exactly this for ONE folder/class:
# 1) Remove near-duplicate images (pHash)
# 2) If images > 150 -> randomly keep only 150 (delete rest)
# 3) If images < 150 -> create augmented images until total = 150
#
# Usage (Windows):
#   python aphid_150_dedup_augment.py --folder "C:\Users\lenovo t480s\Desktop\wheat diseases\aphid" --max_images 150 --dedup_threshold 6
#
# Install once:
#   pip install numpy pillow

import argparse, random, math
from pathlib import Path
from collections import defaultdict
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

IMG_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

def is_image(p: Path) -> bool:
    return p.suffix.lower() in IMG_EXTS

def list_images(folder: Path):
    imgs = [p for p in folder.iterdir() if p.is_file() and is_image(p)]
    imgs.sort(key=lambda x: x.name.lower())
    return imgs

# ---------------- pHash (needs numpy) ----------------
def phash(img: Image.Image, hash_size=8, highfreq_factor=4) -> int:
    import numpy as np
    img = img.convert("L")
    size = hash_size * highfreq_factor
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    x = np.asarray(img, dtype=np.float32)

    N = size
    n = np.arange(N)
    k = n.reshape((N, 1))
    dct_mat = np.cos((math.pi / N) * (n + 0.5) * k)
    dct_mat[0, :] *= 1.0 / math.sqrt(2)
    dct_mat *= math.sqrt(2 / N)
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

def dedup_in_folder(folder: Path, threshold: int):
    imgs = list_images(folder)
    hashes = []
    removed = 0

    for p in imgs:
        try:
            with Image.open(p) as im:
                im = ImageOps.exif_transpose(im)
                h = phash(im)
        except Exception:
            # unreadable -> remove
            try: p.unlink()
            except: pass
            removed += 1
            continue

        dup = any(hamming(h, prev_h) <= threshold for prev_h in hashes)
        if dup:
            try: p.unlink()
            except: pass
            removed += 1
        else:
            hashes.append(h)

    return removed

# ---------------- Augmentation ----------------
def augment_pil(img: Image.Image) -> Image.Image:
    img = img.convert("RGB")

    # flip
    if random.random() < 0.5:
        img = ImageOps.mirror(img)

    # small rotate
    if random.random() < 0.6:
        angle = random.uniform(-12, 12)
        img = img.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)

    # crop-resize
    if random.random() < 0.7:
        w, h = img.size
        scale = random.uniform(0.65, 1.0)
        nw, nh = int(w * scale), int(h * scale)
        if nw > 20 and nh > 20 and nw <= w and nh <= h:
            left = random.randint(0, max(0, w - nw))
            top = random.randint(0, max(0, h - nh))
            img = img.crop((left, top, left + nw, top + nh)).resize((w, h), Image.Resampling.LANCZOS)

    # color jitter
    if random.random() < 0.85:
        img = ImageEnhance.Brightness(img).enhance(random.uniform(0.8, 1.25))
        img = ImageEnhance.Contrast(img).enhance(random.uniform(0.8, 1.25))
        img = ImageEnhance.Color(img).enhance(random.uniform(0.8, 1.25))

    # blur
    if random.random() < 0.15:
        img = img.filter(ImageFilter.GaussianBlur(radius=random.uniform(0.2, 1.0)))

    return img

def trim_to_max(folder: Path, max_images: int, seed: int):
    imgs = list_images(folder)
    if len(imgs) <= max_images:
        return 0
    random.Random(seed).shuffle(imgs)
    to_delete = imgs[max_images:]
    for p in to_delete:
        try: p.unlink()
        except: pass
    return len(to_delete)

def augment_to_reach(folder: Path, max_images: int, seed: int, copies_cap_per_image: int):
    random.seed(seed)
    imgs = list_images(folder)
    cur = len(imgs)
    if cur >= max_images or cur == 0:
        return 0

    needed = max_images - cur
    per_src = defaultdict(int)
    created = 0

    # safety to avoid infinite loops
    safety = 0
    max_safety = needed * 100

    while cur < max_images and safety < max_safety:
        safety += 1
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
        out_path = folder / out_name
        if out_path.exists():
            per_src[str(src)] += 1
            continue

        aug.save(out_path, quality=95)
        per_src[str(src)] += 1
        created += 1
        cur += 1

    return created

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--folder", required=True, help="Single class folder path")
    ap.add_argument("--max_images", type=int, default=150, help="Final total images (default 150)")
    ap.add_argument("--dedup_threshold", type=int, default=6, help="4 strict, 6 normal, 8 loose")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--copies_cap_per_image", type=int, default=10, help="Max augmented copies per original image")
    args = ap.parse_args()

    folder = Path(args.folder).expanduser().resolve()
    if not folder.exists() or not folder.is_dir():
        raise SystemExit(f"ERROR: Folder not found: {folder}")

    before = len(list_images(folder))
    if before == 0:
        raise SystemExit("ERROR: No images found in this folder.")

    # 1) Dedup
    removed_dups = dedup_in_folder(folder, args.dedup_threshold)

    after_dedup = len(list_images(folder))

    # 2) Trim if > max
    removed_trim = trim_to_max(folder, args.max_images, args.seed)

    after_trim = len(list_images(folder))

    # 3) Augment if < max
    created_aug = augment_to_reach(folder, args.max_images, args.seed, args.copies_cap_per_image)

    final = len(list_images(folder))

    print("\n✅ DONE")
    print("Folder:", folder)
    print("Before:", before)
    print("Removed duplicates:", removed_dups)
    print("Removed (trim to max):", removed_trim)
    print("Created (aug):", created_aug)
    print("Final total:", final)
    if final != args.max_images:
        print(f"⚠ Note: final total is {final}, not {args.max_images}. If your folder had very few images, increase --copies_cap_per_image.")

if __name__ == "__main__":
    main()