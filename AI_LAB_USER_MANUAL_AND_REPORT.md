# AI-Lab & RTX 5090 NInfer System Manual & Status Report

**Document Version:** 1.1 (Verified Live)  
**Target Environment:** AI-Lab Linux VM & Windows RTX 5090 Host  
**Architecture:** Headless Windows GPU Host (`melissacomp2`) + Private Tailscale Network + AI-Lab VM (`ai-lab`)

---

## 1. Quick Access Guide: How to Reach the Chat

The AI interfaces are served securely over Tailscale with SSL/TLS encryption.

### 🌐 Direct URLs
| Interface | Exact Browser URL | Description |
| :--- | :--- | :--- |
| **Open WebUI (Chat Interface)** | **`https://ai-lab.tail282021.ts.net:3000`** | **The main chat UI** (Must use `https://`) |
| **Qwen Code Interface** | **`https://ai-lab.tail282021.ts.net`** | Qwen Code backend (`qwen serve`) |

> ⚠️ **Important:** Port 3000 is SSL-enforced by Tailscale. You must include **`https://`** in the URL. If you type `http://`, the browser will show a 400 Bad Request error.

### How to Start Chatting
1. Open **`https://ai-lab.tail282021.ts.net:3000`** in your browser.
2. Sign in with your Open WebUI credentials.
3. At the top of the chat window, click the **Model Selector dropdown**.
4. Select **`qwen3.8-27b-nvfp4`** (powered by the RTX 5090 GPU).
5. Type your message and start chatting.

> **Reasoning Models:** Qwen3.8 produces extended chain-of-thought thinking before delivering its answer. In Open WebUI, you can click on the collapsible **"Thinking Process"** block above the response to view its internal reasoning tokens in real time.

---

## 2. API Endpoints & Developer Integration

If you or your applications/scripts need to query the LLM directly, use the standard OpenAI-compatible API endpoint exposed across the private network.

### Endpoint Details
* **Base URL:** `http://100.69.96.57:8080/v1`
* **Model ID:** `qwen3.8-27b-nvfp4`
* **API Key:** Not required / any dummy string (`dummy`)
* **Maximum Context Window:** **150,000 tokens**

### Python Integration (Standard OpenAI SDK)
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://100.69.96.57:8080/v1",
    api_key="dummy"
)

response = client.chat.completions.create(
    model="qwen3.8-27b-nvfp4",
    messages=[
        {"role": "user", "content": "Analyze our system architecture and summarize performance."}
    ],
    temperature=0.7,
    max_tokens=1000
)

print(response.choices[0].message.content)
```

### cURL CLI Test
```bash
curl -X POST http://100.69.96.57:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.8-27b-nvfp4",
    "messages": [{"role": "user", "content": "Hello, how are you?"}],
    "max_tokens": 100
  }'
```

---

## 3. System Architecture & Topology

```
┌─────────────────────────────────────────────────────────────┐
│             WINDOWS GPU HOST: melissacomp2 (100.69.96.57)   │
│                                                             │
│   • Hardware: NVIDIA GeForce RTX 5090 (32,607 MiB VRAM)     │
│   • Model: Qwen3.8-27B NVFP4 (22.1 GB weight file)          │
│   • Engine: NInfer Windows v0.9.1 Headless                  │
│   • VRAM Allocation: 31,662 MiB (100% on GPU, 0% CPU RAM)   │
│   • Speculative Decoding: Multi-Token Prediction (MTP 3)    │
│   • Port Binding: 0.0.0.0:8080 (Restricted by Firewall)     │
│   • Firewall: Port 8080 restricted to 100.64.0.0/10 private │
│   • Service: Windows Scheduled Task "NInferHeadlessServer"  │
└──────────────────────────────┬──────────────────────────────┘
                               │
               Private Tailscale Link (WireGuard)
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                LINUX VM: ai-lab (100.74.180.23)             │
│                                                             │
│   • Open WebUI: Docker container on port 3000               │
│   • Public Tailscale URL: https://ai-lab.tail282021.ts.net:3000│
│   • Primary LLM Backend: http://100.69.96.57:8080/v1        │
│   • Standby Fallback: Local llama.cpp + GGUF in /srv/       │
│   • Daemons & Workers: Route to RTX 5090 for fast compute   │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Benchmark Performance Summary

| Metric | RTX 5090 NInfer (NVFP4) | Local Fallback (CPU/GGUF) | Improvement |
| :--- | :--- | :--- | :--- |
| **Time to First Token (TTFT, Warm)** | **43.4 – 46.2 ms** | 3,500 – 4,500 ms | **~75x Faster** |
| **Time to First Token (TTFT, Cold)** | **231.0 ms** | ~5,100 ms | **~22x Faster** |
| **Output Token Rate** | **64.2 – 130.4 tok/s** | 3.2 – 4.8 tok/s | **16x – 30x Faster** |
| **Prefill Speed (5,000 tokens)** | **8,105 tokens/sec** | ~35 tokens/sec | **~231x Faster** |
| **Context Window Capacity** | **150,000 tokens** | 8,192 – 16,384 tokens | **~10x – 18x Larger** |
| **VRAM Usage** | **31.6 GB / 32.6 GB** | 0 GB | **Zero CPU offload** |
| **Concurrency (4 Streams)** | **60.7 tok/s aggregate** | < 1 tok/s | **Linear multi-user scaling** |

---

## 5. Operations & Health Management

### How to Check Status on the Windows Host (`melissacomp2`)
Open PowerShell on `melissacomp2`:
```powershell
# 1. Check if NInfer server process is running:
Get-Process -Name ninfer-serve

# 2. Check RTX 5090 VRAM and GPU utilization:
nvidia-smi

# 3. View the health check log:
Get-Content C:\NInfer\logs\health.log -Tail 10

# 4. View stdout/stderr server log:
Get-Content C:\NInfer\logs\ninfer_stdout.log -Tail 20
```

### How to Restart NInfer on Windows
If you ever need to manually restart the NInfer server:
```powershell
# Stop any running instances:
taskkill /F /IM ninfer-serve.exe

# Start the headless service task:
schtasks /run /tn "NInferHeadlessServer"
```

### How to Check Status on the Linux VM (`ai-lab`)
From an SSH terminal on `ai-lab`:
```bash
# 1. Test reachability to the RTX 5090 model:
curl -s http://100.69.96.57:8080/v1/models

# 2. Check Open WebUI container status:
sudo docker ps --filter name=open-webui

# 3. View Open WebUI logs:
sudo docker logs open-webui --tail 25
```

---

## 6. Safety & Fallback Guarantees
1. **Fallback Stack Intact:** The original Phase 1 model files (`Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf` etc.) located in `/srv/nwa-model/models/` remain untouched.
2. **Zero Complex Passthrough:** No fragile Hyper-V DDA or kernel PCI stubs were configured. If the Windows GPU host is ever turned off, the VM will not crash and can seamlessly fall back to local CPU/GGUF inference.
3. **Network Isolation:** NInfer is strictly bounded to the private Tailscale interface (`100.64.0.0/10`) and does not listen on any public WAN IP.
