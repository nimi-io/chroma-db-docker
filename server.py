from chromadb.config import Settings
from chromadb.app import app
import uvicorn

def main():
    settings = Settings(
        chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
        chroma_server_host="0.0.0.0",
        chroma_server_http_port=8000,
        anonymized_telemetry=False,
        persist_directory="/app/data"
    )

    # Start the ChromaDB server using Uvicorn
    uvicorn.run(app, host=settings.chroma_server_host, port=settings.chroma_server_http_port)

if __name__ == "__main__":
    main()
