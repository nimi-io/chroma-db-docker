FROM python:3.11-slim

ENV CHROMA_PERSIST_DIRECTORY=/data \
    CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
    ANONYMIZED_TELEMETRY=False \
    CHROMA_SERVER_HOST=0.0.0.0 \
    CHROMA_SERVER_HTTP_PORT=8000

# Install chromadb with numpy<2.0
RUN pip install --no-cache-dir "numpy<2.0" chromadb==0.5.23 uvicorn

RUN mkdir -p /data && chmod 777 /data

EXPOSE 8000

# Initialize ChromaDB on first run, then start server
CMD python3 -c "import chromadb; from chromadb.config import Settings; chromadb.PersistentClient(path='/data', settings=Settings(anonymized_telemetry=False))" && \
    uvicorn chromadb.app:app --host 0.0.0.0 --port 8000 --timeout-keep-alive 600 --timeout-graceful-shutdown 600 --log-level info


    




# # Use official ChromaDB image
# FROM python:3.11-slim

# # Environment variables
# ENV CHROMA_PERSIST_DIRECTORY=/data \
#     CHROMA_SERVER_CORS_ALLOW_ORIGINS='["*"]' \
#     ANONYMIZED_TELEMETRY=false

# # Install chromadb
# RUN pip install --no-cache-dir chromadb==0.4.15 uvicorn

# # Create persistence directory
# RUN mkdir -p /data

# # Expose Chroma API port
# EXPOSE 8000

# # Start Chroma with extended timeouts
# CMD ["uvicorn", "chromadb.app:app","--host", "0.0.0.0","--port", "8000","--timeout-keep-alive", "600","--timeout-graceful-shutdown", "600"]
