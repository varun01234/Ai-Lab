# Qwen Daemon Backend Verification & Completion Plan

**Client:** Rico (DataismLab)  
**Consultant / Engineer:** Varun Chaturvedi  
**Scope:** Pre-Model Backend Completion, Certification & Integration Testing (Excluding GPU/Model Infrastructure)  
**Date:** October 7, 2026  
**Document Version:** 2.0.0 (Updated Post-Environment Verification)  

---

## 1. Verified System Baseline (Live Server Audit)

All components listed as "already in place" were inspected directly on `labadmin@100.74.180.23` and confirmed functional:

| Component | Verified Status | Live Server Evidence |
| :--- | :---: | :--- |
| **Ubuntu AI-Lab VM** | **VERIFIED (PASS)** | Ubuntu 24.04.5 LTS (Kernel 7.0.0-1014-azure) |
| **Qwen Code 0.25.0** | **VERIFIED (PASS)** | `/usr/bin/qwen` version `0.25.0` present |
| **Qwen Serve / ACP Service** | **VERIFIED (PASS)** | `nwa-qwen.service` active and serving on `100.74.180.23:4170` |
| **Official Qwen Docker Image** | **VERIFIED (PASS)** | `ghcr.io/qwenlm/qwen-code:0.25.0` present locally (939 MB) |
| **Qwen Docker Sandbox Config**| **VERIFIED (PASS)** | `30-vendor-sandbox.conf` set to `QWEN_SANDBOX=docker` |
| **Agent Definitions** | **VERIFIED (PASS)** | `/srv/nwa/home/.qwen/agents/{foreman.md, worker.md, compliance.md}` active |
| **Tailscale Connectivity** | **VERIFIED (PASS)** | IP `100.74.180.23` active, serving `https://ai-lab.tail282021.ts.net` |
| **Daemon Workspace Structure** | **VERIFIED (PASS)** | `/srv/nwa/workspaces/{data, knowledge, logs, outputs, projects, reviews, tmp}` initialized |

> [!NOTE]
> **Preservation Rule:** Existing operational configurations, services (`dataism-foreman.service`, `dataism-gate.service`, `nwa-qwen.service`), and systemd drop-ins will NOT be rebuilt, overwritten, or reinstalled.

---

## 2. Focused Scope of Work: The 5 Remaining Backend Deliverables

*GPU passthrough (RTX 5090), CUDA drivers, inference server (vLLM), and model weight downloads are strictly EXCLUDED as requested.*

### Task 1: Sandbox Certification & Fail-Closed Isolation
- Verify that Qwen execution runs strictly within the container and fails closed.
- Ensure zero privileged flags, absence of Docker socket (`/var/run/docker.sock`) mounts, and no host-root filesystem leaks.
- Test read-only rootfs behavior and disposable container escape barriers.
- Deliver automated proof confirming no unauthorized host file changes can occur.

### Task 2: MCP & Tools Configuration & Call Verification
- Complete Qwen-native MCP setup without duplicating built-in shell/file/web tools.
- Configure approved MCP server endpoints (including GitHub MCP) non-interactively using `--consent` to prevent CLI prompt blocking.
- Execute and verify end-to-end tool call invocations through Qwen CLI and ACP.

### Task 3: Working Persistent Memory & RAG Retrieval Layer
- Connect the working retrieval layer to the pre-created `/srv/nwa/workspaces/knowledge/` and `/srv/nwa/workspaces/memory/` stores.
- Implement the retrieval cycle: **Store → Retrieve → Cross-session persistence**.
- Use native Qwen memory indexing or minimal native embedding retrieval (avoiding heavy custom third-party frameworks).
- Validate document indexing and prompt retrieval recall across distinct sessions.

### Task 4: Permissions & Approval Enforcement (Foreman / Worker / Compliance)
- Enforce strict boundaries between roles:
  - **Foreman:** Plans, delegates, and coordinates; destructive commands blocked.
  - **Worker:** Bounded task execution within the workspace.
  - **Compliance:** Independent read-only auditing and interceptor.
- Connect commands to the running approval gate (`/opt/ai-lab/gate/gate.py` on ports 8770/8771) to ensure all destructive, privilege-escalating, network-altering, or persistence actions require explicit human confirmation.

### Task 5: Final Pre-Model Acceptance Test Suite
- Run comprehensive integration tests validating:
  1. Foreman → Worker task delegation over ACP.
  2. Compliance interception and blocking of unapproved commands.
  3. Sandbox confinement under execution stress.
  4. MCP tool calls execution and response return.
  5. Persistent memory retrieval across session boundaries.
- Produce a formal **Pre-Model Certification Report** with definitive PASS / PARTIAL / FAIL verdicts and raw terminal evidence.

### Task 6: Model Download & Staging (Confirmed with Client)
- Coordinate and confirm the exact Hugging Face repositories with Rico prior to initiating downloads:
  - **Main Model:** 27B class abliterated model
  - **Coding Model:** 30–35B class abliterated model
  - **Worker/Utility:** 9B class abliterated model
- Stage downloads cleanly via `huggingface-cli` using verified checksums.

### Task 7: Model Jail Quarantine & Boundary Enforcement
- Place all downloaded model weights strictly into the dedicated model quarantine directory (`/srv/nwa-model/models/`).
- Set strict ownership (`root:nwa-model 750`) ensuring zero write access by untrusted processes.
- Ensure model files have zero access to host credentials, private user files (`/home/labadmin`), or network sockets.
- Leave models staged in quarantine without activating or deploying runtime execution.

### Task 8: Unified Daemon User Interface Setup
- Configure and finalize the clean Daemon communication UI (Open WebUI connected to the local backend).
- Bind to the existing Qwen/Daemon backend (`nwa-qwen.service` on port 4170 / ACP) ensuring single-pane access to conversations and logs.
- Pre-configure interface endpoints so it is ready to hook into the model router once GPU/inference is connected.

---

## 3. Timeline & Delivery

- **Turnaround:** **Within 12 to 18 Hours** (Expedited Same-Day Delivery)
- **Delivery Flow:**
  1. Phase 1: Sandbox isolation certification & MCP tool call verification.
  2. Phase 2: Memory / RAG working retrieval layer & approval gate enforcement.
  3. Phase 3: Model HF confirmation & quarantine staging in Model Jail.
  4. Phase 4: Unified Daemon UI integration & final pre-model test suite execution.

---

## 4. Commercial Offer

### Fixed Turnkey Investment (All-Inclusive)
- **Total Project Fee:** **$125 USD** (approx. **₹10,900 INR**)
- **Turnaround:** **Within 12 to 18 Hours**
- **Covers All 8 Deliverables (Including All 3 Additions):**
  1. Sandbox certification (fail-closed isolation, zero docker socket or host root leaks).
  2. MCP / tools configuration (non-interactive setup with `--consent`, call verification).
  3. Memory / RAG working retrieval layer (store → retrieve → cross-session persistence).
  4. Permissions & approval gate enforcement across Foreman, Worker, and Compliance.
  5. Final pre-model test suite and formal PASS/PARTIAL/FAIL evidence report.
  6. **[Added]** Model staging (27B, 30–35B, 9B abliterated models - confirmed HF repos).
  7. **[Added]** Model Jail quarantine isolation (permissions, no host leaks, unactivated).
  8. **[Added]** Unified Daemon User Interface connected to backend.

*Payment Terms:*
- **50% Advance Deposit:** $62.50 USD upon kickoff.
- **50% Final Payment:** $62.50 USD upon delivery and verification of the PASS/PARTIAL/FAIL Acceptance Report.  
*(Or full single invoice upon delivery as per client preference).*

---

## 5. Ready-to-Send Client Message (Draft for Rico)

```text
Hi Rico,

Yes, absolutely! I confirm that all three additions:
1. Downloading and staging the three Qwen abliterated models (27B main, 30–35B coding, 9B worker) with HF repos confirmed with you first.
2. Placing them strictly in the dedicated Model Jail / Quarantine with isolated permissions (no credentials, no host file access, unactivated).
3. Setting up the clean Daemon User Interface connected to the existing backend and pre-wired for the future model router.

...are FULLY INCLUDED in the scope and locked into the flat $125 USD price with delivery within 12 to 18 hours.

Summary of Included Deliverables ($125 flat):
✔ Live-verified baseline preservation (no rebuilding of existing components).
✔ Sandbox certification (isolated, fail-closed, no Docker socket or host root mounts).
✔ Removal of any unauthorized /home/labadmin container mounts.
✔ Qwen-native MCP setup & live tool call verification.
✔ Working Memory/RAG retrieval layer (store -> retrieve -> cross-session persistence).
✔ Permissions & approval gate enforcement across Foreman, Worker, and Compliance.
✔ Download & staging of the 3 abliterated models into Model Jail (repositories confirmed with you before download).
✔ Daemon User Interface setup ready for the backend & future model router.
✔ Comprehensive final test suite with PASS/PARTIAL/FAIL evidence report.

Please share or confirm the exact Hugging Face repository IDs you'd like me to stage for the 27B, 30–35B, and 9B models, and I will begin the implementation and staging right away!

Best regards,
Varun
```
