# app/main.py

from opentelemetry import trace, metrics
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource

import os
import time
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app.model import predict

# OTel setup — points to the Collector we'll deploy in this lab
OTEL_COLLECTOR_ENDPOINT = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-collector.monitoring:4317")

resource = Resource.create({
    "service.name": "inference-api",
    "service.version": "1.0.0",
    "deployment.environment": os.getenv("ENVIRONMENT", "dev"),
})

# Traces
trace_provider = TracerProvider(resource=resource)
trace_provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint=OTEL_COLLECTOR_ENDPOINT, insecure=True))
)
trace.set_tracer_provider(trace_provider)
tracer = trace.get_tracer(__name__)

# Metrics
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint=OTEL_COLLECTOR_ENDPOINT, insecure=True)
)
metric_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(metric_provider)
meter = metrics.get_meter(__name__)

# Custom metric — track predictions by sentiment
prediction_counter = meter.create_counter(
    "inference_predictions_total",
    description="Total number of predictions made, by sentiment",
)

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

# Auto-instrument FastAPI — generates spans for every request automatically
FastAPIInstrumentor.instrument_app(app)


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
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    if len(request.text) > 1000:
        raise HTTPException(status_code=400, detail="Text too long — max 1000 characters")

    with tracer.start_as_current_span("sentiment_prediction") as span:
        span.set_attribute("text.length", len(request.text))

        logger.info(f"Predicting sentiment for: {request.text[:50]}...")
        result = predict(request.text)
        logger.info(f"Prediction: {result['sentiment']} ({result['confidence']})")

        span.set_attribute("prediction.sentiment", result["sentiment"])
        span.set_attribute("prediction.confidence", result["confidence"])

        # Increment custom metric, labeled by sentiment
        prediction_counter.add(1, {"sentiment": result["sentiment"]})

    return result


@app.get("/metrics")
async def metrics():
    """Basic metrics endpoint."""
    return {
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "model_version": "1.0.0",
    }