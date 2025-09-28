from fastapi import FastAPI
from chromadb.config import Settings
import chromadb
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# 1. ChromaDB client (embedded in server)
chroma_client = chromadb.Client(Settings(
    chroma_db_impl="duckdb+parquet",
    persist_directory="/data"
))

# 2. Load SmolLM (CPU mode)
MODEL_ID = "HuggingFaceTB/SmolLM2-360M"  # second option 1.7B if needed
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
model = AutoModelForCausalLM.from_pretrained(MODEL_ID, torch_dtype=torch.float32)
model.eval()

# 3. FastAPI app
app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/query")
async def query(question: str):
    # Retrieve from Chroma
    collection = chroma_client.get_or_create_collection("manuals")
    results = collection.query(query_texts=[question], n_results=3)
    context = " ".join(results["documents"][0]) if results["documents"] else ""

    # Build prompt
    prompt = f"Context: {context}\n\nQuestion: {question}\nAnswer:"

    # Generate with SmolLM
    inputs = tokenizer(prompt, return_tensors="pt")
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=200,
            do_sample=True,
            temperature=0.7
        )
    answer = tokenizer.decode(outputs[0], skip_special_tokens=True)

    return {"question": question, "answer": answer, "context": context}
