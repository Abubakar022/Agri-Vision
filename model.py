import io
from typing import List

import torch
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image

import timm  # Swin Transformer models

# Device select
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Tumhari wheat disease classes:
CLASS_NAMES: List[str] = [
    "Aphid",
    "Black Rust",
    "Blast",
    "Brown Rust",
    "Fusarium Head Blight",
    "Healthy",
    "Leaf Blight",
    "Mildew",
    "Mite",
    "Septoria",
    "Smut",
    "Stem Fly",
    "Tan Spot",
    "Unknown",
    "Yellow Rust",
]


def build_model(num_classes: int):
    """
    Yahan wohi Swin model banaya gaya hai jo training ke waqt use hona chahiye.
    Agar tumne training me koi aur variant use kiya ho
    (e.g. 'swin_base_patch4_window7_224'), to model name yahan change kar do.
    """
    model = timm.create_model(
        "swin_tiny_patch4_window7_224",  # CHANGE karo agar training me koi aur variant use kia tha
        pretrained=False,
        num_classes=num_classes,
    )
    return model


_model = None  # cached model instance


def load_model(weights_path: str = "model.pth"):
    """
    Model ko load karta hai. Tumhara checkpoint full dict hai:
    { 'epoch', 'model_state_dict', 'optimizer_state_dict', 'val_acc', 'class_names', ... }
    is liye yahan se sirf model_state_dict nikala ja raha hai.
    """
    global _model, CLASS_NAMES
    if _model is not None:
        return _model

    model = build_model(num_classes=len(CLASS_NAMES))

    checkpoint = torch.load(weights_path, map_location=DEVICE)

    # Case 1: training me full checkpoint save kia gaya tha
    # e.g. torch.save({
    #   'epoch': ...,
    #   'model_state_dict': model.state_dict(),
    #   'optimizer_state_dict': optimizer.state_dict(),
    #   'val_acc': ...,
    #   'class_names': class_names_list,
    # }, 'model.pth')
    if isinstance(checkpoint, dict) and "model_state_dict" in checkpoint:
        state_dict = checkpoint["model_state_dict"]

        # optionally checkpoint se classes bhi load kar sakte hain:
        if "class_names" in checkpoint:
            try:
                # ensure list of str
                CLASS_NAMES = [str(c) for c in checkpoint["class_names"]]
            except Exception:
                # agar kuch issue ho to hardcoded classes hi use karo
                pass

    # Case 2: kuch log "state_dict" key use karte hain
    elif isinstance(checkpoint, dict) and "state_dict" in checkpoint:
        state_dict = checkpoint["state_dict"]

    # Case 3: direct state_dict save kia gaya tha
    else:
        state_dict = checkpoint

    # Ab clean state_dict load ho raha hai
    model.load_state_dict(state_dict)
    model.to(DEVICE)
    model.eval()

    _model = model
    return _model


# Image preprocessing pipeline
transform = transforms.Compose([
    transforms.Resize((224, 224)),  # agar training size different tha to yahan same size rakho
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


def prepare_image(image_bytes: bytes) -> torch.Tensor:
    """Raw image bytes ko tensor (batch size 1) me convert karta hai."""
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    tensor = transform(image).unsqueeze(0)  # shape: [1, C, H, W]
    return tensor.to(DEVICE)


def predict(image_bytes: bytes, top_k: int = 1):
    """Run inference on raw image bytes and return ONLY the top class."""
    model = load_model()

    input_tensor = prepare_image(image_bytes)

    with torch.no_grad():
        logits = model(input_tensor)
        probs = F.softmax(logits, dim=1)[0]

    # Top-1 only
    top_prob, top_idx = torch.topk(probs, k=1)

    idx = int(top_idx.item())
    prob = float(top_prob.item())

    # Safe class name
    class_name = CLASS_NAMES[idx] if idx < len(CLASS_NAMES) else f"class_{idx}"

    return [{
        "class_index": idx,
        "class_name": class_name,
        "probability": prob,
    }]

    return results
