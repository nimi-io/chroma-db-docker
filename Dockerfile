# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=8000
ENV ANONYMIZED_TELEMETRY=False
ENV PERSIST_DIRECTORY=/app/data
ENV MODEL_NAME=HuggingFaceTB/smollm-135m

# Put Hugging Face cache inside /app
ENV TRANSFORMERS_CACHE=/app/hf_cache
ENV HF_HOME=/app/hf_cache

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
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for caching layers)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cpu

# Create directories and fix permissions
RUN mkdir -p /app/data /app/hf_cache && chown -R chroma:chroma /app

# Copy server script
COPY main_server.py /app/main_server.py
COPY healthcheck.py /app/healthcheck.py

# Preload smolLM so it’s cached inside /app/hf_cache
RUN python -c "from transformers import AutoTokenizer, AutoModelForCausalLM; \
    AutoTokenizer.from_pretrained('${MODEL_NAME}'); \
    AutoModelForCausalLM.from_pretrained('${MODEL_NAME}')"

# Switch to non-root
USER chroma

# Expose port
EXPOSE 8000

# Health check (validates both Chroma + smolLM in one app)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python /app/healthcheck.py

# Start unified server
CMD ["python", "/app/main_server.py"]
