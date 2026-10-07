import urllib.request

urls = [
    ('27B Standard Q4_K', 'https://huggingface.co/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF/resolve/main/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf'),
    ('27B UD-Q4_K_XL', 'https://huggingface.co/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF/resolve/main/Huihui-Qwen3.8-27B-abliterated-UD-Q4_K_XL.gguf'),
    ('30B Coder Q4_K_M', 'https://huggingface.co/mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF/resolve/main/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf'),
    ('8B Worker safetensors 1', 'https://huggingface.co/huihui-ai/Huihui-Qwen3-8B-abliterated-v2/resolve/main/model-00001-of-00004.safetensors'),
    ('8B Worker safetensors 2', 'https://huggingface.co/huihui-ai/Huihui-Qwen3-8B-abliterated-v2/resolve/main/model-00002-of-00004.safetensors'),
    ('8B Worker safetensors 3', 'https://huggingface.co/huihui-ai/Huihui-Qwen3-8B-abliterated-v2/resolve/main/model-00003-of-00004.safetensors'),
    ('8B Worker safetensors 4', 'https://huggingface.co/huihui-ai/Huihui-Qwen3-8B-abliterated-v2/resolve/main/model-00004-of-00004.safetensors'),
]

for name, u in urls:
    req = urllib.request.Request(u, method='HEAD')
    try:
        with urllib.request.urlopen(req) as resp:
            sz = int(resp.headers.get('Content-Length', 0))
            print(f'{name}: {sz:,} bytes ({sz / (1024**3):.2f} GiB)')
    except Exception as e:
        print(f'{name}: Error {e}')
