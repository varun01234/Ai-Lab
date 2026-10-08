#!/usr/bin/env bash
set -uo pipefail

JAIL_BASE="/srv/nwa-model/models"
LOG_FILE="/var/log/nwa-model/download.log"

mkdir -p "$JAIL_BASE/main-27b" "$JAIL_BASE/coder-30b" "$JAIL_BASE/worker-8b"
mkdir -p /var/log/nwa-model
chown -R root:nwa-model "$JAIL_BASE"
chmod 750 "$JAIL_BASE" "$JAIL_BASE/main-27b" "$JAIL_BASE/coder-30b" "$JAIL_BASE/worker-8b"

echo "==========================================================" | tee -a "$LOG_FILE"
echo "  MODEL JAIL STAGING & ACCELERATED QUARANTINE DOWNLOAD    " | tee -a "$LOG_FILE"
echo "  Timestamp: $(date -u)" | tee -a "$LOG_FILE"
echo "==========================================================" | tee -a "$LOG_FILE"

# 1. 27B Main Model
echo "" | tee -a "$LOG_FILE"
echo ">>> [1/3] Checking 27B Main Model: Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf" | tee -a "$LOG_FILE"
DEST_27B="$JAIL_BASE/main-27b/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf"
URL_27B="https://huggingface.co/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF/resolve/main/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf"

if [ -f "$DEST_27B" ] && [ ! -f "$DEST_27B.aria2" ] && [ $(stat -c%s "$DEST_27B") -ge 16000000000 ]; then
    echo "  [ALREADY COMPLETE] 27B Model present ($(stat -c%s "$DEST_27B") bytes)" | tee -a "$LOG_FILE"
else
    while true; do
        aria2c -x 16 -s 16 -k 1M -c --file-allocation=none --summary-interval=5 \
            --max-tries=0 --retry-wait=5 \
            -d "$JAIL_BASE/main-27b" -o "Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf" \
            "$URL_27B" 2>&1 | tee -a "$LOG_FILE"
        if [ -f "$DEST_27B" ] && [ ! -f "$DEST_27B.aria2" ] && [ $(stat -c%s "$DEST_27B") -ge 16000000000 ]; then
            break
        fi
        sleep 3
    done
fi

# 2. 30B Coding Model
echo "" | tee -a "$LOG_FILE"
echo ">>> [2/3] Checking/Resuming 30B Coding Model: Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf" | tee -a "$LOG_FILE"
DEST_30B="$JAIL_BASE/coder-30b/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf"
URL_30B="https://huggingface.co/mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF/resolve/main/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf"

if [ -f "$DEST_30B" ] && [ ! -f "$DEST_30B.aria2" ] && [ $(stat -c%s "$DEST_30B") -ge 18000000000 ]; then
    echo "  [ALREADY COMPLETE] 30B Coding Model present ($(stat -c%s "$DEST_30B") bytes)" | tee -a "$LOG_FILE"
else
    while true; do
        aria2c -x 16 -s 16 -k 1M -c --file-allocation=none --summary-interval=5 \
            --max-tries=0 --retry-wait=5 \
            -d "$JAIL_BASE/coder-30b" -o "Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf" \
            "$URL_30B" 2>&1 | tee -a "$LOG_FILE"
        if [ -f "$DEST_30B" ] && [ ! -f "$DEST_30B.aria2" ] && [ $(stat -c%s "$DEST_30B") -ge 18000000000 ]; then
            break
        fi
        sleep 3
    done
fi

# 3. 8B Worker Model
echo "" | tee -a "$LOG_FILE"
echo ">>> [3/3] Checking/Resuming 8B Worker Model: huihui-ai/Huihui-Qwen3-8B-abliterated-v2" | tee -a "$LOG_FILE"
BASE_8B="https://huggingface.co/huihui-ai/Huihui-Qwen3-8B-abliterated-v2/resolve/main"
FILES_8B=(
    "config.json"
    "generation_config.json"
    "model.safetensors.index.json"
    "tokenizer.json"
    "tokenizer_config.json"
    "vocab.json"
    "merges.txt"
    "model-00001-of-00004.safetensors"
    "model-00002-of-00004.safetensors"
    "model-00003-of-00004.safetensors"
    "model-00004-of-00004.safetensors"
)

for f in "${FILES_8B[@]}"; do
    DEST_F="$JAIL_BASE/worker-8b/$f"
    if [ -f "$DEST_F" ] && [ ! -f "$DEST_F.aria2" ] && [ $(stat -c%s "$DEST_F") -gt 100 ]; then
        echo "  [ALREADY COMPLETE] $f ($(stat -c%s "$DEST_F") bytes)" | tee -a "$LOG_FILE"
    else
        echo "  Downloading/Resuming $f..." | tee -a "$LOG_FILE"
        while true; do
            aria2c -x 16 -s 16 -k 1M -c --file-allocation=none --summary-interval=5 \
                --max-tries=0 --retry-wait=5 \
                -d "$JAIL_BASE/worker-8b" -o "$f" \
                "$BASE_8B/$f" 2>&1 | tee -a "$LOG_FILE"
            if [ -f "$DEST_F" ] && [ ! -f "$DEST_F.aria2" ]; then
                break
            fi
            sleep 3
        done
    fi
done

echo "" | tee -a "$LOG_FILE"
echo ">>> [4/4] Enforcing Strict Quarantine Security Permissions..." | tee -a "$LOG_FILE"
chown -R root:nwa-model "$JAIL_BASE"
find "$JAIL_BASE" -type d -exec chmod 750 {} +
find "$JAIL_BASE" -type f -exec chmod 640 {} +

echo "" | tee -a "$LOG_FILE"
echo "==========================================================" | tee -a "$LOG_FILE"
echo "  MODEL JAIL STAGING & QUARANTINE COMPLETE!               " | tee -a "$LOG_FILE"
echo "==========================================================" | tee -a "$LOG_FILE"
ls -lh "$JAIL_BASE/main-27b" | tee -a "$LOG_FILE"
ls -lh "$JAIL_BASE/coder-30b" | tee -a "$LOG_FILE"
ls -lh "$JAIL_BASE/worker-8b" | tee -a "$LOG_FILE"
df -h "$JAIL_BASE" | tee -a "$LOG_FILE"
