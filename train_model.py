import pandas as pd
from datasets import Dataset
from transformers import AutoTokenizer, AutoModelForSequenceClassification, TrainingArguments, Trainer
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, f1_score
import numpy as np
import os

# --- File Path ---
FILE_NAME = r"C:\Users\LENOVO\Documents\Training_data.xlsx - Sheet1.csv.xlsx"

TEXT_COLUMN = "user_input_urdu"
LABEL_COLUMN = "detected_disease"
MODEL_CHECKPOINT = "bert-base-multilingual-cased"
MAX_LENGTH = 128
OUTPUT_DIR = "./urdu_disease_classifier_results"

# --- Updated TRAINING_ARGS compatible with latest transformers ---
TRAINING_ARGS = {
    'output_dir': OUTPUT_DIR,
    'num_train_epochs': 3,
    'per_device_train_batch_size': 8,
    'per_device_eval_batch_size': 8,
    'warmup_steps': 500,
    'weight_decay': 0.01,
    'logging_dir': './logs',
    'logging_steps': 10,
}


# --- Load Data ---
try:
    df = pd.read_excel(FILE_NAME)
    print("File loaded successfully!")
except FileNotFoundError:
    print(f"ERROR: File not found at: {FILE_NAME}")
    exit()

# --- Select and rename columns ---
df = df[[TEXT_COLUMN, LABEL_COLUMN]]
df.columns = ['text', 'label_str']

# --- Encode labels ---
label_encoder = LabelEncoder()
df['labels'] = label_encoder.fit_transform(df['label_str'])

label_to_id = {name: i for i, name in enumerate(label_encoder.classes_)}
id_to_label = {i: name for name, i in label_to_id.items()}
num_labels = len(label_to_id)

print(f"Total number of classes: {num_labels}")
print("Classes:", label_to_id)

# --- Split data ---
train_df, eval_df = train_test_split(df, test_size=0.2, stratify=df['labels'], random_state=42)

train_dataset = Dataset.from_dict({
    "text": train_df["text"].tolist(),
    "labels": train_df["labels"].tolist()
})

eval_dataset = Dataset.from_dict({
    "text": eval_df["text"].tolist(),
    "labels": eval_df["labels"].tolist()
})

# --- Tokenization ---
tokenizer = AutoTokenizer.from_pretrained(MODEL_CHECKPOINT)

def tokenize_function(examples):
    return tokenizer(examples["text"], truncation=True, padding="max_length", max_length=MAX_LENGTH)

tokenized_train_dataset = train_dataset.map(tokenize_function, batched=True)
tokenized_eval_dataset = eval_dataset.map(tokenize_function, batched=True)

tokenized_train_dataset.set_format("torch", columns=["input_ids", "attention_mask", "labels"])
tokenized_eval_dataset.set_format("torch", columns=["input_ids", "attention_mask", "labels"])

# --- Model ---
model = AutoModelForSequenceClassification.from_pretrained(
    MODEL_CHECKPOINT,
    num_labels=num_labels,
    id2label=id_to_label,
    label2id=label_to_id
)

# --- Metrics ---
def compute_metrics(p):
    preds = np.argmax(p.predictions, axis=1)
    return {
        "accuracy": accuracy_score(p.label_ids, preds),
        "f1": f1_score(p.label_ids, preds, average="weighted")
    }

# --- Trainer ---
training_args = TrainingArguments(**TRAINING_ARGS)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train_dataset,
    eval_dataset=tokenized_eval_dataset,
    tokenizer=tokenizer,
    compute_metrics=compute_metrics
)

print("\n--- Training Started ---")
trainer.train()

print("\n--- Final Evaluation ---")
metrics = trainer.evaluate()
print(metrics)

trainer.save_model(f"{OUTPUT_DIR}/final_model")
tokenizer.save_pretrained(f"{OUTPUT_DIR}/final_model")

print(f"\nModel saved to: {OUTPUT_DIR}/final_model")
