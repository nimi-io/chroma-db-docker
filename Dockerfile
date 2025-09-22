# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000

# Create a non-root user
RUN groupadd -r chroma && useradd -r -g chroma chroma

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install ChromaDB
RUN pip install --no-cache-dir chromadb

# Create directories for data persistence
RUN mkdir -p /app/data && chown -R chroma:chroma /app

# Switch to non-root user
USER chroma

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/api/v1/heartbeat')" || exit 1

# Start ChromaDB server
CMD ["python", "-m", "chromadb.cli.cli", "run", "--host", "0.0.0.0", "--port", "8000", "--path", "/app/data"]
