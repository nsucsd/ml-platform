# app/model.py
# Simple sentiment model — the ML part is intentionally simple
# The infrastructure around it is the point

import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline


def build_model() -> Pipeline:
    """Build and train a simple sentiment classifier."""
    # Training data — simple positive/negative examples
    texts = [
        "excellent product love it amazing great fantastic",
        "good quality works well happy satisfied",
        "okay decent average not bad acceptable",
        "poor quality disappointed bad terrible awful",
        "worst product ever hate it broken useless",
        "highly recommend best purchase ever outstanding",
        "fast delivery great service wonderful experience",
        "returns were easy helpful customer support",
        "completely broken waste of money regret buying",
        "never buying again terrible experience horrible",
    ]
    labels = [1, 1, 0, 0, 0, 1, 1, 1, 0, 0]
    # 1 = positive, 0 = negative

    pipeline = Pipeline([
        ("tfidf", TfidfVectorizer(max_features=1000)),
        ("clf", LogisticRegression(random_state=42)),
    ])
    pipeline.fit(texts, labels)
    return pipeline


# Train once at module load time
_model = build_model()


def predict(text: str) -> dict:
    """Return sentiment prediction for input text."""
    prediction = _model.predict([text])[0]
    probabilities = _model.predict_proba([text])[0]

    return {
        "text": text,
        "sentiment": "positive" if prediction == 1 else "negative",
        "confidence": round(float(max(probabilities)), 3),
        "scores": {
            "negative": round(float(probabilities[0]), 3),
            "positive": round(float(probabilities[1]), 3),
        }
    }