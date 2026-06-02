FROM chromadb/chroma:1.5.0

ENV IS_PERSISTENT=true

EXPOSE 8000

CMD ["run", "--host", "0.0.0.0", "--port", "8000", "--path", "/data"]




# FROM python:3.11-slim

# RUN pip install --no-cache-dir "numpy<2.0" chromadb==1.0.3

# RUN mkdir -p /data && chmod 777 /data

# EXPOSE 8000

# CMD python3 -c "import chromadb; print(f'ChromaDB version: {chromadb.__version__}')" && \
#     chroma run --path /data --host 0.0.0.0 --port 8000


