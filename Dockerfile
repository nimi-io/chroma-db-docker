# Use Python slim image
FROM python:3.11-slim

# Environment variables
ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=false

# Install deps
RUN pip install --no-cache-dir \
    chromadb==0.4.15 \
    fastapi \
    uvicorn \
    torch \
    transformers \
    accelerate

# Create persistence directory
RUN mkdir -p /data

# Copy your FastAPI server file
WORKDIR /app
COPY server.py /app/server.py

# Expose port
EXPOSE 8000

# Healthcheck
HEALTHCHECK CMD curl --fail http://localhost:8000/health || exit 1

# Start FastAPI (looking for `app` inside server.py)
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
