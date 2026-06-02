FROM chromadb/chroma:1.5.0

RUN mkdir -p /data && chmod 777 /data

ENV IS_PERSISTENT=true
ENV CHROMA_HOST_ADDR=0.0.0.0
ENV CHROMA_HOST_PORT=8000

EXPOSE 8000

CMD ["run", "--path", "/data", "--host", "0.0.0.0", "--port", "8000"]




# FROM python:3.11-slim

# RUN pip install --no-cache-dir "numpy<2.0" chromadb==1.0.3

# RUN mkdir -p /data && chmod 777 /data

# EXPOSE 8000

# CMD python3 -c "import chromadb; print(f'ChromaDB version: {chromadb.__version__}')" && \
#     chroma run --path /data --host 0.0.0.0 --port 8000


