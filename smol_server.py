from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
import asyncio

MODEL_NAME = "HuggingFaceTB/smollm-135m"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME)

app = FastAPI(title="smolLM Server")

class PromptRequest(BaseModel):
    prompt: str
    max_new_tokens: int = 128


async def _generate_text(prompt: str, max_new_tokens: int = 128) -> str:
    """Run blocking transformer generation in a thread."""
    def _blocking_generate():
        inputs = tokenizer(prompt, return_tensors="pt")
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=0.7
        )
        return tokenizer.decode(outputs[0], skip_special_tokens=True)

    return await asyncio.to_thread(_blocking_generate)


@app.post("/generate")
async def generate_text(req: PromptRequest):
    text = await _generate_text(req.prompt, req.max_new_tokens)
    return {"response": text}


def start_smol():
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)


if __name__ == "__main__":
    start_smol()
