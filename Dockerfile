# Use official ChromaDB image
FROM ghcr.io/chroma-core/chroma:0.4.15

# Environment variables
ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=false

# Create persistence directory
RUN mkdir -p /data

# Expose Chroma API port
EXPOSE 8000

# Start Chroma with uvicorn
CMD ["uvicorn", "chromadb.server.fastapi.app:app", "--host", "0.0.0.0", "--port", "8000"]
