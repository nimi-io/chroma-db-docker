from chromadb.config import Settings
from chromadb.server import main as chroma_main

def main():
    settings = Settings(
        chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
        chroma_server_host="0.0.0.0",
        chroma_server_http_port=8000,
        anonymized_telemetry=False,
        persist_directory="/app/data"
    )
    
    # Start the ChromaDB server
    chroma_main(settings)

if __name__ == "__main__":
    main()
