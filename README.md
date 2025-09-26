# ChromaDB Docker Setup

A Docker-based setup for ChromaDB, the AI-native open-source embedding database.

## Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd chroma-db-docker
   ```

2. Start ChromaDB:
   ```bash
   docker-compose up -d
   ```

3. Verify the service is running:
   ```bash
   curl http://localhost:8000/api/v1/heartbeat
   ```

## Configuration Update

The ChromaDB server will be available at `http://localhost:8000`.

### Environment Variables

- `CHROMA_SERVER_HOST`: Server host (default: 0.0.0.0)
- `CHROMA_SERVER_HTTP_PORT`: Server port (default: 8000)
- `CHROMA_SERVER_CORS_ALLOW_ORIGINS`: CORS origins (default: ["*"])

### Data Persistence

Data is persisted in a Docker volume named `chromadb_data`. To backup or inspect the data:

```bash
# Backup data
docker run --rm -v chromadb_data:/data -v $(pwd):/backup alpine tar czf /backup/chromadb-backup.tar.gz -C /data .

# Restore data
docker run --rm -v chromadb_data:/data -v $(pwd):/backup alpine tar xzf /backup/chromadb-backup.tar.gz -C /data
```

## Usage Examples

### Python Client

```python
import chromadb
from chromadb.config import Settings

# Connect to the ChromaDB server
client = chromadb.HttpClient(
    host="localhost",
    port=8000,
    settings=Settings(allow_reset=True)
)

# Create a collection
collection = client.create_collection("my_collection")

# Add documents
collection.add(
    documents=["This is a document", "This is another document"],
    metadatas=[{"source": "my_source"}, {"source": "my_source"}],
    ids=["id1", "id2"]
)

# Query the collection
results = collection.query(
    query_texts=["This is a query document"],
    n_results=2
)

print(results)
```

### JavaScript/TypeScript Client

```javascript
import { ChromaApi, Configuration } from 'chromadb';

const chroma = new ChromaApi(new Configuration({
    basePath: "http://localhost:8000"
}));

// Create a collection
const collection = await chroma.createCollection({
    name: "my_collection"
});

// Add documents
await chroma.add({
    collectionName: "my_collection",
    addEmbedding: {
        ids: ["id1", "id2"],
        documents: ["This is a document", "This is another document"],
        metadatas: [{"source": "my_source"}, {"source": "my_source"}]
    }
});

// Query the collection
const results = await chroma.getNearestNeighbors({
    collectionName: "my_collection",
    queryEmbedding: {
        queryTexts: ["This is a query document"],
        nResults: 2
    }
});

console.log(results);
```

## Management Commands

### Start the service
```bash
docker-compose up -d
```

### Stop the service
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f chromadb
```

### Restart the service
```bash
docker-compose restart chromadb
```

### Build custom image
```bash
docker-compose build
```

## Troubleshooting

### Check service health
```bash
docker-compose ps
curl http://localhost:8000/api/v1/heartbeat
```

### View detailed logs
```bash
docker-compose logs chromadb
```

### Reset data (⚠️ This will delete all data)
```bash
docker-compose down -v
docker-compose up -d
```

## Development

For development purposes, you can mount your local code:

```yaml
# Add this to docker-compose.yml under chromadb service
volumes:
  - chromadb_data:/app/data
  - ./src:/app/src  # Mount local source code
```

## API Documentation

Once the service is running, you can access:
- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/api/v1/heartbeat`
- Version Info: `http://localhost:8000/api/v1/version`

## License

This project is licensed under the Apache License 2.0.
