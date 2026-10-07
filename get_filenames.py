#!/usr/bin/env python3
import urllib.request
import json

url = "https://huggingface.co/api/models/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF"
req = urllib.request.Request(url, headers={"User-Agent": "curl/7.81.0"})
with urllib.request.urlopen(req, timeout=10) as resp:
    data = json.loads(resp.read().decode())
    q4_files = [s["rfilename"] for s in data.get("siblings", []) if "Q4" in s["rfilename"] or "q4" in s["rfilename"]]
    print("Q4 files in 27B repo:", q4_files)

url2 = "https://huggingface.co/api/models/mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF"
req2 = urllib.request.Request(url2, headers={"User-Agent": "curl/7.81.0"})
with urllib.request.urlopen(req2, timeout=10) as resp:
    data2 = json.loads(resp.read().decode())
    q4_files2 = [s["rfilename"] for s in data2.get("siblings", []) if "Q4" in s["rfilename"] or "q4" in s["rfilename"]]
    print("Q4 files in 30B repo:", q4_files2)

url3 = "https://huggingface.co/api/models/huihui-ai/Huihui-Qwen3-8B-abliterated-v2"
req3 = urllib.request.Request(url3, headers={"User-Agent": "curl/7.81.0"})
with urllib.request.urlopen(req3, timeout=10) as resp:
    data3 = json.loads(resp.read().decode())
    files3 = [s["rfilename"] for s in data3.get("siblings", []) if s["rfilename"].endswith((".safetensors", ".json", ".txt"))]
    print("Files in 8B repo:", files3)
