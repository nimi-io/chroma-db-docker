# healthcheck.py
import sys, requests

def check_chroma():
    r = requests.get("http://localhost:8000/heartbeat", timeout=5)
    r.raise_for_status()

def check_smol():
    r = requests.post("http://localhost:8001/generate", json={"prompt": "ping"}, timeout=10)
    r.raise_for_status()

if __name__ == "__main__":
    try:
        check_chroma()
        check_smol()
    except Exception as e:
        print("Healthcheck failed:", e)
        sys.exit(1)
