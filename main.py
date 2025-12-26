from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .model import predict
from .schemas import PredictionResponse, PredictionItem

app = FastAPI(
    title="Swin Transformer Inference API",
    version="1.0.0"
)

# CORS (adjust allow_origins in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"message": "Swin Transformer backend is running 🚀"}


@app.post("/predict", response_model=PredictionResponse)
async def predict_endpoint(file: UploadFile = File(...)):
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="Only JPEG/PNG images are supported.")

    image_bytes = await file.read()

    try:
        preds = predict(image_bytes)
    except FileNotFoundError:
        raise HTTPException(
            status_code=500,
            detail=(
                "model.pth not found. Please copy your trained weights file into the "
                "project folder and rename it to 'model.pth'."
            ),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return PredictionResponse(
        predictions=[PredictionItem(**p) for p in preds]
    )
