# Use Python slim image
FROM python:3.11-slim

# Environment variables
ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=false

# Install deps: chromadb + FastAPI + smolLM + uvicorn
RUN pip install --no-cache-dir \
    chromadb==0.4.15 \
    fastapi \
    uvicorn \
    torch \
    transformers \
    accelerate

# Create persistence directory
RUN mkdir -p /data

# Expose FastAPI port
EXPOSE 8000

# Start FastAPI app (both Chroma + SmolLM endpoints)
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
