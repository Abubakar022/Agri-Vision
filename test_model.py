import torch
import torch.nn.functional as F
from PIL import Image
from torchvision import transforms
import timm
import tkinter as tk
from tkinter import filedialog, messagebox

# ===== MODEL PATH =====
model_path = r"C:\Users\lenovo t480s\Desktop\upadted fyp\best_wheat_model.pth"

# ===== REAL CLASS NAMES (training order) =====
classes = [
    "Aphid",
    "Black Rust",
    "Blast",
    "Brown Rust",
    "Common Root Rot",
    "Fusarium Head Blight",
    "Healthy",
    "Leaf Blight",
    "Loose Smut",
    "Mildew",
    "Mite",
    "Septoria",
    "Stem Rust",
    "Tan Spot",
    "Yellow Rust",
    "Other"
]

# ===== SELECT IMAGE =====
root = tk.Tk()
root.withdraw()

image_path = filedialog.askopenfilename(
    title="Select Wheat Leaf Image",
    filetypes=[("Image files", "*.jpg *.jpeg *.png")]
)

if not image_path:
    print("No image selected.")
    exit()

# ===== DEVICE =====
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ===== LOAD MODEL =====
model = timm.create_model("tf_efficientnetv2_m.in1k", pretrained=False, num_classes=16)
state_dict = torch.load(model_path, map_location=device)
model.load_state_dict(state_dict)

model.to(device)
model.eval()

# ===== IMAGE TRANSFORM =====
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
])

# ===== LOAD IMAGE =====
image = Image.open(image_path).convert("RGB")
image_tensor = transform(image).unsqueeze(0).to(device)

# ===== PREDICTION =====
with torch.no_grad():
    outputs = model(image_tensor)
    probs = F.softmax(outputs, dim=1)
    confidence, predicted = torch.max(probs, 1)

disease_name = classes[predicted.item()]
confidence_score = confidence.item() * 100

# ===== RESULT =====
print("\n==============================")
print(" Wheat Disease Prediction")
print("==============================")
print("Disease Detected:", disease_name)
print("Confidence:", round(confidence_score, 2), "%")

# ===== POPUP WINDOW =====
messagebox.showinfo(
    "Prediction Result",
    f"Disease Detected: {disease_name}\nConfidence: {confidence_score:.2f}%"
)