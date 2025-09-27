# Use official ChromaDB server image
FROM ghcr.io/chroma-core/chroma:0.4.15

# Set environment variables for persistence & config
ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=false

# Create data directory
RUN mkdir -p /data

# Mount Railway's persistent volume (optional if you want persistence)
VOLUME ["/data"]

# Expose ChromaDB API port
EXPOSE 8000

# Run chroma server (already ENTRYPOINT in base image, but explicit for clarity)
CMD ["chroma", "run", "--path", "/data", "--host", "0.0.0.0", "--port", "8000"]
