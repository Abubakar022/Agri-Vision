Swin Backend (FastAPI) Skeleton
===============================

Steps to use:

1) Copy your trained model weights file into this folder and rename it to:
   model.pth

2) Open app/model.py and:
   - Change CLASS_NAMES list to your actual class names.
   - Adjust build_model() to match exactly how you created your Swin model during training
     (same architecture name, image size, num_classes, etc.).

3) Create a virtual environment (Windows example, in CMD):

   cd path\to\swin_backend
   python -m venv venv
   venv\Scripts\activate

4) Install dependencies:

   pip install -r requirements.txt

5) Run the server:

   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

6) Open in browser:

   http://127.0.0.1:8000       -> Health check
   http://127.0.0.1:8000/docs  -> Swagger UI for testing /predict

Note: This project is a skeleton. You MUST plug in the same Swin model definition you
used during training inside app/model.py (inside build_model()) and set CLASS_NAMES.
