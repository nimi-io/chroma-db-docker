# server.py
import os
from chromadb.server.fastapi import FastAPI

from chromadb.config import Settings
from chromadb.server.fastapi import create_app

# Environment variables
HOST = os.getenv("CHROMA_SERVER_HOST", "0.0.0.0")
PORT = int(os.getenv("CHROMA_SERVER_HTTP_PORT", 8000))
PERSIST_DIR = os.getenv("PERSIST_DIRECTORY", "/app/data")
ANONYMIZED_TELEMETRY = os.getenv("ANONYMIZED_TELEMETRY", "False").lower() == "true"

# Chroma settings
settings = Settings(
    chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
    persist_directory=PERSIST_DIR,
    anonymized_telemetry=ANONYMIZED_TELEMETRY
)

# Create the FastAPI app
app = create_app(settings)

# Run with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT)



# from chromadb.config import Settings
# from chromadb.app import app
# import uvicorn

# def main():
#     settings = Settings(
#         chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
#         chroma_server_host="0.0.0.0",
#         chroma_server_http_port=8000,
#         anonymized_telemetry=False,
#         persist_directory="/app/data"
#     )

#     # Serving ChromaDB server using Uvicorn
#     uvicorn.run(app, host=settings.chroma_server_host, port=int(settings.chroma_server_http_port))

# if __name__ == "__main__":
#     main()
