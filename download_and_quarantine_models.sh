#!/usr/bin/env bash
set -uo pipefail

JAIL_BASE="/srv/nwa-model/models"
LOG_FILE="/var/log/nwa-model/download.log"

echo "=== MODEL JAIL STAGING & QUARANTINE DOWNLOAD ==="
echo "Target Jail: $JAIL_BASE"
echo "Timestamp: $(date -u)"

mkdir -p "$JAIL_BASE/main-27b" "$JAIL_BASE/coder-30b" "$JAIL_BASE/worker-8b"
mkdir -p /var/log/nwa-model
chown -R root:nwa-model "$JAIL_BASE"
chmod 750 "$JAIL_BASE" "$JAIL_BASE/main-27b" "$JAIL_BASE/coder-30b" "$JAIL_BASE/worker-8b"

echo
echo "--- 1. Staging 27B Main Model (Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf) ---"
URL_27B="https://huggingface.co/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF/resolve/main/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf"
DEST_27B="$JAIL_BASE/main-27b/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf"
if [ -f "$DEST_27B" ] && [ $(stat -c%s "$DEST_27B") -ge 16000000000 ]; then
    echo "  [EXISTS] 27B Main Model already fully downloaded ($(stat -c%s "$DEST_27B") bytes)"
else
    echo "  Downloading 27B model to quarantine..."
    wget -c -q --show-progress "$URL_27B" -O "$DEST_27B"
fi

echo
echo "--- 2. Staging 30B Coding Model (Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf) ---"
URL_30B="https://huggingface.co/mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-GGUF/resolve/main/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf"
DEST_30B="$JAIL_BASE/coder-30b/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf"
if [ -f "$DEST_30B" ] && [ $(stat -c%s "$DEST_30B") -ge 18000000000 ]; then
    echo "  [EXISTS] 30B Coding Model already fully downloaded ($(stat -c%s "$DEST_30B") bytes)"
else
    echo "  Downloading 30B model to quarantine..."
    wget -c -q --show-progress "$URL_30B" -O "$DEST_30B"
fi

echo
echo "--- 3. Staging 8B Worker Model (huihui-ai/Huihui-Qwen3-8B-abliterated-v2) ---"
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
    if [ -f "$DEST_F" ] && [ $(stat -c%s "$DEST_F") -gt 100 ]; then
        echo "  [EXISTS] $f already present ($(stat -c%s "$DEST_F") bytes)"
    else
        echo "  Downloading $f..."
        wget -c -q --show-progress "$BASE_8B/$f" -O "$DEST_F"
    fi
done

echo
echo "--- 4. Applying Strict Quarantine Permissions ---"
chown -R root:nwa-model "$JAIL_BASE"
find "$JAIL_BASE" -type d -exec chmod 750 {} +
find "$JAIL_BASE" -type f -exec chmod 640 {} +

echo
echo "=== MODEL JAIL STAGING COMPLETE ==="
ls -lh "$JAIL_BASE/main-27b"
ls -lh "$JAIL_BASE/coder-30b"
ls -lh "$JAIL_BASE/worker-8b"
echo
df -h "$JAIL_BASE"
