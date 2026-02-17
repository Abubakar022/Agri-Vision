from pydantic import BaseModel
from typing import List


class PredictionItem(BaseModel):
    class_index: int
    class_name: str
    probability: float


class PredictionResponse(BaseModel):
    predictions: List[PredictionItem]
