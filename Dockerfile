# Use official ChromaDB image
FROM python:3.11-slim

# Environment variables
ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=false

# Install chromadb
RUN pip install --no-cache-dir chromadb==0.4.15 uvicorn

# Create persistence directory
RUN mkdir -p /data

# Expose Chroma API port
EXPOSE 8000

# Start Chroma with uvicorn
CMD ["uvicorn", "chromadb.app:app", "--host", "0.0.0.0", "--port", "8000"]
