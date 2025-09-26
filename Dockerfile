# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000
ENV ANONYMIZED_TELEMETRY=False
ENV PERSIST_DIRECTORY=/app/data

# Create a non-root user
RUN groupadd -r chroma && useradd -r -g chroma chroma

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    sqlite3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install ChromaDB
# RUN pip install --no-cache-dir chromadb==0.4.15 requests
RUN pip install --no-cache-dir "chromadb[server]==1.0.20" requests

# Create data directory and give permissions
RUN mkdir -p /app/data && chown -R chroma:chroma /app

# Copy server script
COPY server.py /app/server.py

# Switch to non-root user
USER chroma

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/heartbeat', timeout=5)" || exit 1

# Start ChromaDB server
CMD ["python", "/app/server.py"]
