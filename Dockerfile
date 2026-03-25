FROM python:3.11-slim

RUN pip install --no-cache-dir "numpy<2.0" chromadb==1.0.3

RUN mkdir -p /data && chmod 777 /data

EXPOSE 8000

CMD python3 -c "import chromadb; print(f'ChromaDB version: {chromadb.__version__}')" && \
    chroma run --path /data --host 0.0.0.0 --port 8000


# CMD python3 -c "import chromadb; print(f'ChromaDB version: {chromadb.__version__}')" && \
#     python3 -c "import chromadb; from chromadb.config import Settings; chromadb.PersistentClient(path='/data', settings=Settings(anonymized_telemetry=False))" && \
#     uvicorn chromadb.app:app --host 0.0.0.0 --port 8000 --timeout-keep-alive 600 --timeout-graceful-shutdown 600 --log-level info


# CMD python3 -c "import chromadb; from chromadb.config import Settings; chromadb.PersistentClient(path='/data', settings=Settings(anonymized_telemetry=False))" && \
#     uvicorn chromadb.app:app --host 0.0.0.0 --port 8000 --timeout-keep-alive 600 --timeout-graceful-shutdown 600 --log-level info







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
