# Qwen Daemon Backend Verification & Completion Plan

**Client:** Rico (DataismLab)  
**Consultant / Engineer:** Varun Chaturvedi  
**Scope:** Complete Pre-Model Backend, Security Certification, Model Staging & Quarantine, and Daemon UI  
**Date:** October 7, 2026  
**Document Version:** 3.0.0 (Turnkey Scope with Model Staging & UI)  

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

## 2. Complete Scope of Deliverables

### Task 1: Sandbox Certification & Fail-Closed Isolation
- Verify that Qwen execution runs strictly within the container and fails closed.
- Ensure zero privileged flags, absence of Docker socket (`/var/run/docker.sock`) mounts, and no host-root filesystem leaks.
- Ensure personal files (`/home/labadmin`) are completely detached and protected from container mounts.
- Deliver automated proof confirming no unauthorized host file changes can occur.

### Task 2: MCP & Tools Configuration & Call Verification
- Complete Qwen-native MCP setup without duplicating built-in shell/file/web tools.
- Configure approved MCP server endpoints (including GitHub MCP) non-interactively using `--consent`.
- Execute and verify end-to-end tool call invocations through Qwen CLI and ACP.

### Task 3: Working Persistent Memory & RAG Retrieval Layer
- Connect the working retrieval layer to the pre-created `/srv/nwa/workspaces/knowledge/` and `/srv/nwa/workspaces/memory/` stores.
- Implement the retrieval cycle: **Store → Retrieve → Cross-session persistence** using official vendor MCP memory tools.
- Validate document indexing and prompt retrieval recall across distinct sessions.

### Task 4: Permissions & Approval Enforcement (Foreman / Worker / Compliance)
- Enforce strict boundaries between roles (Foreman plans, Worker executes bounded tasks, Compliance audits).
- Connect commands to the running approval gate (`/opt/ai-lab/gate/gate.py` on ports 8770/8771) ensuring destructive, privilege-escalating, network-altering, or persistence actions require human confirmation.

### Task 5: Final Pre-Model Acceptance Test Suite
- Run comprehensive integration tests validating Foreman delegation, Compliance interception, sandbox containment, MCP tools, and memory retrieval.
- Produce a formal **Pre-Model Certification Report** with definitive PASS / PARTIAL / FAIL verdicts and raw terminal evidence.

### Task 6: Model Download & Staging (Confirmed with Client)
- Coordinate and confirm exact Hugging Face repositories with Rico prior to downloading:
  - **Main Model:** 27B class abliterated model
  - **Coding Model:** 30–35B class abliterated model
  - **Worker/Cleanup:** 9B class abliterated model
- Stage downloads cleanly into quarantine storage using verified checksums.

### Task 7: Model Jail Quarantine & Boundary Enforcement
- Place all downloaded model weights strictly into the dedicated model quarantine directory (`/srv/nwa-model/models/`).
- Set strict ownership (`root:nwa-model 750`) ensuring zero write access by untrusted processes.
- Ensure model files have zero access to host credentials, private user files (`/home/labadmin`), or network sockets.
- Staged without runtime activation or deployment.

### Task 8: Unified Daemon User Interface Setup
- Configure and finalize the clean Daemon communication UI (Open WebUI connected to local backend).
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
  6. **[Included]** Model staging (27B, 30–35B, 9B abliterated models - confirmed HF repos).
  7. **[Included]** Model Jail quarantine isolation (permissions, no host leaks, unactivated).
  8. **[Included]** Unified Daemon User Interface connected to backend.

*Payment Terms:*
- **50% Advance Deposit:** $62.50 USD upon kickoff.
- **50% Final Payment:** $62.50 USD upon delivery and verification of the PASS/PARTIAL/FAIL Acceptance Report.  
*(Or full single invoice upon delivery as per client preference).*
