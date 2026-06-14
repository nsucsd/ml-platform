# app/main.py

import os
import time
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app.model import predict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Track startup time for uptime metric
START_TIME = time.time()


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("ML Inference API starting up")
    logger.info(f"Environment: {os.getenv('ENVIRONMENT', 'unknown')}")
    yield
    logger.info("ML Inference API shutting down")


app = FastAPI(
    title="ML Inference API",
    description="Sentiment analysis inference service — ML Platform Observatory",
    version="1.0.0",
    lifespan=lifespan,
)


class PredictRequest(BaseModel):
    text: str

    class Config:
        json_schema_extra = {
            "example": {"text": "This product is absolutely amazing!"}
        }


class PredictResponse(BaseModel):
    text: str
    sentiment: str
    confidence: float
    scores: dict


@app.get("/health")
async def health():
    """Health check endpoint — used by GKE liveness probe."""
    return {
        "status": "healthy",
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
    }


@app.get("/ready")
async def ready():
    """Readiness check — used by GKE readiness probe."""
    return {"status": "ready"}


@app.post("/predict", response_model=PredictResponse)
async def predict_sentiment(request: PredictRequest):
    """Run sentiment prediction on input text."""
    if not request.text.strip():
        raise HTTPException(
            status_code=400,
            detail="Text cannot be empty"
        )

    if len(request.text) > 1000:
        raise HTTPException(
            status_code=400,
            detail="Text too long — max 1000 characters"
        )

    logger.info(f"Predicting sentiment for: {request.text[:50]}...")
    result = predict(request.text)
    logger.info(f"Prediction: {result['sentiment']} ({result['confidence']})")

    return result


@app.get("/metrics")
async def metrics():
    """Basic metrics endpoint."""
    return {
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "model_version": "1.0.0",
    }