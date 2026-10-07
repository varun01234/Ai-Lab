# Memory Analysis, Tailscale Serve Verification & Model Staging Update

## 1. VM Memory Analysis & Process Breakdown (`ai-lab`)

Per Rico's request, we inspected memory usage and process footprint on the VM without modifying the allocation.

### Memory Summary (`free -h`)
- **Total VM RAM Allocated:** **7.6 GiB** (configured as an 8,192 MB VM in Hyper-V)
- **Currently Used:** **1.8 GiB**
- **Free:** **366 MiB**
- **Buff / Cache:** **5.8 GiB** (mostly OS page cache from active model writing)
- **Available Memory:** **5.8 GiB**
- **Swap Allocated:** **0 B** (no swapfile or swap partition enabled)

### Top Processes Consuming Memory (`ps -eo ... --sort=-rss`)
1. **Open WebUI Container (`python3`):** 830 MB (10.4% of RAM) — web application backend & UI engine.
2. **Grafana (`grafana-server`):** 231 MB (2.8% of RAM) — metrics & telemetry.
3. **Qwen ACP Serve (`node`):** 195 MB (2.4% of RAM) — protocol gateway.
4. **Docker Daemon (`dockerd`):** 93 MB (1.1% of RAM).
5. **System Journal & Tailscale (`systemd-journal`, `tailscaled`):** ~120 MB total.
6. **AI Foreman & Approval Gate (`uvicorn`, `python3`):** ~62 MB total.
7. **Postgres Database (`postgres`):** ~39 MB total.
8. **Active Model Downloader (`aria2c`):** 30 MB (0.3% of RAM).

### Recommendation for Phase 2 Model Activation:
- **Current Risk:** The three models being staged are **16.8 GB** (27B Q4_K), **18.5 GB** (30B Coder Q4_K_M), and **16 GB** (8B). Even when running inference on the RTX 5090 (32GB VRAM), inference runtimes (llama.cpp / Ollama / vLLM) use system memory during initial model ingestion, memory-mapping (`mmap`), weight staging, and context window buffers.
- If the VM only has **8 GB total RAM** and **0 swap**, loading a 16.8 GB or 18.5 GB model into memory can trigger the Linux Out-Of-Memory (OOM) killer, crashing the runtime.
- **Recommendation:** Before activating Phase 2 inference:
  1. Increase the VM memory allocation in Hyper-V to **32 GB minimum** (or **48 GB – 64 GB** if the physical host has ample headroom).
  2. Configure a **16 GB swapfile** on the NVMe SSD as a safety buffer against transient spikes.
- *Status:* **No changes to VM memory allocation have been made**, pending your confirmation.

---

## 2. Private Tailscale Access for Open WebUI (Enabled & Verified)

We enabled the official Tailscale Serve mapping as approved:

- **Command Executed:**
  ```bash
  sudo tailscale serve --bg --https=3000 --yes http://127.0.0.1:3000
  ```
- **Active Tailscale Serve State (`tailscale serve status`):**
  ```text
  https://ai-lab.tail282021.ts.net:3000 (tailnet only)
  |-- / proxy http://127.0.0.1:3000
  ```
- **Live Tailnet Verification:**
  Queried `https://ai-lab.tail282021.ts.net:3000/` and received:
  `HTTP/2 200 OK` (uvicorn service, 11,318 bytes).
- **Private Tailscale URL for Rico:**
  **`https://ai-lab.tail282021.ts.net:3000/`**
- **Public Exposure Check:**
  - Open WebUI remains bound locally to `127.0.0.1:3000`.
  - Port 3000 is **not** exposed to the public internet.
  - The endpoint is marked **tailnet only** and encrypted with Tailscale TLS.

---

## 3. Model Staging Status

- **Active Model:** `Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf`
- **Current Progress:** **6.5 GiB / 15 GiB (41%)**
- **Status:** Uninterrupted, running steadily in quarantine jail (`/srv/nwa-model/models/main-27b/`).
- **Post-Download Verification:** As requested, once the download completes, we will calculate the exact byte size, SHA-256 hash, and verify the Q4_K quant and source repository before any model activation.
- **Security Baseline:** 16/16 certified configuration is 100% preserved.
