import urllib.request
import json

repos = [
    "huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF",
    "mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF",
    "huihui-ai/Huihui-Qwen3-8B-abliterated-v2"
]

for repo in repos:
    url = f"https://huggingface.co/api/models/{repo}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            print(f"=== REPOSITORY: {repo} ===")
            siblings = data.get("siblings", [])
            for s in siblings:
                rfile = s.get("rfilename", "")
                size = s.get("size", "N/A")
                print(f"  - {rfile} (size: {size})")
    except Exception as e:
        print(f"Error querying {repo}: {e}")
