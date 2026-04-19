import tkinter as tk
from tkinter import scrolledtext, messagebox
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import numpy as np

# ---------------- Load Model ----------------
MODEL_PATH = "./urdu_disease_classifier_results/final_model"

try:
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
    model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
    model.eval()  # set model to evaluation mode
except Exception as e:
    print("Error loading model:", e)
    exit()

# ---------------- Functions ----------------
def predict():
    user_input = user_text.get("1.0", tk.END).strip()
    if not user_input:
        messagebox.showwarning("Input Required", "Please type your query!")
        return
    
    # Tokenize input
    inputs = tokenizer(user_input, return_tensors="pt", truncation=True, padding="max_length", max_length=128)
    
    # Get model predictions
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        pred_id = torch.argmax(logits, dim=1).item()
    
    # Map label id to label name
    label_names = model.config.id2label
    predicted_label = label_names[pred_id]
    
    # Display result
    output_text.config(state=tk.NORMAL)
    output_text.insert(tk.END, f"Q: {user_input}\nA: {predicted_label}\n\n")
    output_text.config(state=tk.DISABLED)
    user_text.delete("1.0", tk.END)

# ---------------- GUI ----------------
root = tk.Tk()
root.title("Urdu Disease Classifier Chatbot")
root.geometry("600x500")

# User input
tk.Label(root, text="Type your query in Urdu:").pack(pady=5)
user_text = scrolledtext.ScrolledText(root, height=5, width=70)
user_text.pack(pady=5)

# Submit button
tk.Button(root, text="Ask", command=predict, bg="green", fg="white").pack(pady=5)

# Output area
tk.Label(root, text="Model Response:").pack(pady=5)
output_text = scrolledtext.ScrolledText(root, height=15, width=70, state=tk.DISABLED)
output_text.pack(pady=5)

# Run GUI
root.mainloop()
