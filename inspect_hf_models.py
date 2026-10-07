#!/usr/bin/env python3
import urllib.request
import json

repos = [
    "huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF",
    "mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF",
    "huihui-ai/Huihui-Qwen3-8B-abliterated-v2"
]

print("=== INSPECTING HUGGING FACE MODEL REPOSITORIES ===")
for r in repos:
    url = f"https://huggingface.co/api/models/{r}"
    req = urllib.request.Request(url, headers={"User-Agent": "curl/7.81.0"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            siblings = data.get("siblings", [])
            print(f"\nRepository: {r}")
            print(f"Total files: {len(siblings)}")
            model_files = [s["rfilename"] for s in siblings if s["rfilename"].endswith((".gguf", ".safetensors"))]
            for mf in model_files[:8]:
                print(f"  - {mf}")
            if len(model_files) > 8:
                print(f"  ... and {len(model_files) - 8} more quantization variants")
    except Exception as e:
        print(f"Error accessing {r}: {e}")
