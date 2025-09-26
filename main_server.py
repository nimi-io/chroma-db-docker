# main_server.py
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM
import asyncio

from chromadb.config import Settings
from chromadb.app import app as chroma_app

# -----------------
# Init main FastAPI
# -----------------
app = FastAPI(title="Chroma + smolLM Server")

# Mount chromaDB under /chroma
settings = Settings(
    chroma_db_impl="chromadb.db.impl.sqlite.SqliteDB",
    chroma_server_host="0.0.0.0",
    chroma_server_http_port=8000,
    anonymized_telemetry=False,
    persist_directory="/app/data",
)
app.mount("/chroma", chroma_app)


# -----------------
# smolLM setup
# -----------------
MODEL_NAME = "HuggingFaceTB/smollm-135m"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME)

class PromptRequest(BaseModel):
    prompt: str
    max_new_tokens: int = 128

async def _generate_text(prompt: str, max_new_tokens: int = 128) -> str:
    def _blocking_generate():
        inputs = tokenizer(prompt, return_tensors="pt")
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=0.7,
        )
        return tokenizer.decode(outputs[0], skip_special_tokens=True)

    return await asyncio.to_thread(_blocking_generate)


@app.post("/generate")
async def generate_text(req: PromptRequest):
    text = await _generate_text(req.prompt, req.max_new_tokens)
    return {"response": text}


# -----------------
# Entry point
# -----------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
