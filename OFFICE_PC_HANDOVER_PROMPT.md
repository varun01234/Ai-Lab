# Office PC Handover Prompt & Server Status Guide

## 1. Copy-Paste Prompt for Antigravity on Your Office PC

When you open Antigravity IDE on your office PC after cloning the repo and running `restore_session_on_office_pc.bat`, paste this prompt into the chat:

```markdown
I am continuing our pair-programming session for Client Rico (DataismLab) on the Qwen Daemon project from my office PC. All project code, certification reports, and conversation state have been restored from our GitHub repository (https://github.com/varun01234/Ai-Lab).

Here is the exact state of the project:
1. Commercials: Flat turnkey price is locked at $125 USD (~₹10,900 INR). Never mention hours to the client.
2. Phase 1 Pre-Model Hardening: 100% COMPLETE and certified (16/16 PASS). Full evidence report is at PREMODEL_FINAL_ACCEPTANCE_REPORT.txt.
3. Tailscale & Interfaces:
   - Tailnet account: rixhsurf@
   - VM Tailscale IP: 100.74.180.23 (ai-lab)
   - Open WebUI: Port 3000 (mapped to https://ai-lab.tail282021.ts.net:3000/, tailnet-only, loopback bound)
   - Qwen Code Web Shell: Port 4170 (https://ai-lab.tail282021.ts.net, ACP backend, bearer token auth)
4. Model Staging Status:
   - Model 1 (27B Main): Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf was 60% downloaded (9.4 GiB / 15.0 GiB) into /srv/nwa-model/models/main-27b/ using aria2c with resume (-c) support.
   - Model 2 (30B Coder) & Model 3 (8B Worker): Queued next in quarantine.
   - Note: The VM was powered off by Rico to increase Hyper-V static RAM to 64 GB and disable Dynamic Memory for the RTX 5090.
5. Next Tasks:
   - Check if ai-lab has powered back on.
   - Resume the 27B model download and verify SHA-256 upon completion.
   - Assist Rico with Phase 2 model router / GPU activation when he is ready.

Please review our workspace and confirm you have full context of our current milestone and files.
```

---

## 2. Server & Tailscale Diagnosis: What Happened?

### Is Anything Disconnected?
* **The VM (`ai-lab` at `100.74.180.23`) is currently OFFLINE.**
  - Direct check via `tailscale status`: `100.74.180.23 ai-lab: offline, last seen ~50 minutes ago`.
  - **Reason:** At 09:38, Rico asked whether to allocate 48 GB or 64 GB RAM in Hyper-V. Changing Hyper-V memory allocation and disabling Dynamic Memory requires shutting down the virtual machine. Rico has powered off `ai-lab` on his workstation to apply these settings.

### What is the Progress of the Model Download?
* Right before the VM was shut down, the download was at:
  - **Transferred:** **9.4 GiB / 15.0 GiB (60%)**
  - **File Size on Disk:** 9.5 GB
  - **Safety:** The download was running via `aria2c -c` with the `.aria2` control file saved to disk (`Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf.aria2`).
  - **No Progress Lost:** Because aria2 tracks downloaded chunks, it will resume from 9.4 GiB automatically without re-downloading earlier chunks once the VM boots up.

### Tailscale ID on Your Office System:
* On your current laptop, Tailscale is connected under **`rixhsurf@`** (Rico's Tailscale network).
* **Important:** If your office PC is logged into a *different* Tailscale account (e.g., your personal account):
  - You will **not** be able to ping or SSH to `100.74.180.23` unless your office PC is also logged into `rixhsurf@` (or unless Rico shares the `ai-lab` machine with your personal Tailscale account).
  - To log into Rico's tailnet on your office PC, use the same Tailscale login Rico provided, or use the SSH key (`C:\Users\varun\.ssh\id_ed25519`) which is already authorized in `labadmin`'s `authorized_keys`.
