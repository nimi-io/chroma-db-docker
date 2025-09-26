# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000
ENV SMOL_SERVER_PORT=8001
ENV ANONYMIZED_TELEMETRY=False
ENV PERSIST_DIRECTORY=/app/data
ENV MODEL_NAME=HuggingFaceTB/smollm-135m

# Set Hugging Face cache inside /app
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

# Copy requirements first for layer caching
COPY requirements.txt .

# Install deps (this layer will be cached unless requirements.txt changes)
RUN pip install --upgrade pip && \
    pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cpu

# Create directories and give permissions
RUN mkdir -p /app/data /app/hf_cache && chown -R chroma:chroma /app

# Copy server scripts
COPY chroma_server.py /app/chroma_server.py
COPY smol_server.py /app/smol_server.py
COPY run_all.py /app/run_all.py
COPY healthcheck.py /app/healthcheck.py

# Preload smolLM so container has it cached
# (this runs as root, but cache is inside /app/hf_cache which later belongs to chroma)
RUN python -c "from transformers import AutoTokenizer, AutoModelForCausalLM; \
    AutoTokenizer.from_pretrained('${MODEL_NAME}'); \
    AutoModelForCausalLM.from_pretrained('${MODEL_NAME}')"

# Switch to non-root user
USER chroma

# Expose ports
EXPOSE 8000 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python /app/healthcheck.py

# Start both ChromaDB and smolLM servers
CMD ["python", "/app/run_all.py"]
