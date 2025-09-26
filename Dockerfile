# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000
ENV CHROMA_DB_IMPL=chromadb.db.impl.sqlite.SqliteDB
ENV CHROMA_API_IMPL=chromadb.api.fastapi.FastAPI
ENV ANONYMIZED_TELEMETRY=False

# Create a non-root user
RUN groupadd -r chroma && useradd -r -g chroma chroma

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install ChromaDB with specific version to avoid compatibility issues
RUN pip install --no-cache-dir chromadb==0.4.15

# Create directories for data persistence
RUN mkdir -p /app/data && chown -R chroma:chroma /app

# Create a simple server script
COPY <<EOF /app/server.py
import chromadb
from chromadb.config import Settings
import uvicorn
import os

def main():
    # Configure ChromaDB settings
    settings = Settings(
        chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
        chroma_api_impl="chromadb.api.fastapi.FastAPI",
        chroma_server_host="0.0.0.0",
        chroma_server_http_port=8000,
        anonymized_telemetry=False,
        persist_directory="/app/data"
    )
    
    # Start the server
    uvicorn.run(
        "chromadb.app:app",
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )

if __name__ == "__main__":
    main()
EOF

# Switch to non-root user
USER chroma

# Expose port
EXPOSE 8000

# Health check - fix the endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/api/v1/heartbeat', timeout=5)" || exit 1

# Start ChromaDB server using the Python script
CMD ["python", "/app/server.py"]