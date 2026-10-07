#!/usr/bin/env bash
set -uo pipefail

echo "=============================================="
echo "TASK 1: SANDBOX CERTIFICATION & ISOLATION"
echo "=============================================="
date -u

PASS_COUNT=0
FAIL_COUNT=0

pass() { echo "  [PASS] $*"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { echo "  [FAIL] $*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
info() { echo "  [INFO] $*"; }

# 1. Check official image
QIMG="ghcr.io/qwenlm/qwen-code:0.25.0"
if sudo docker image inspect "$QIMG" >/dev/null 2>&1; then
    pass "Official Qwen Code 0.25.0 image present ($QIMG)"
else
    fail "Official Qwen Code 0.25.0 image missing"
fi

# 2. Check running sandbox container
CID=$(sudo docker ps -q --filter ancestor="$QIMG" | head -1)
if [ -n "$CID" ]; then
    CNAME=$(sudo docker inspect -f '{{.Name}}' "$CID" | sed 's#^/##')
    pass "Qwen sandbox container running: $CNAME ($CID)"

    # Privileged check
    PRIV=$(sudo docker inspect -f '{{.HostConfig.Privileged}}' "$CID")
    if [ "$PRIV" = "false" ]; then
        pass "Privileged container flag is FALSE"
    else
        fail "Privileged container flag is TRUE ($PRIV)"
    fi

    # Docker socket check
    MOUNTS=$(sudo docker inspect -f '{{range .Mounts}}{{.Source}} -> {{.Destination}} ({{.RW}}){{"\n"}}{{end}}' "$CID")
    info "Active Mounts in $CNAME:"
    echo "$MOUNTS" | sed 's/^/    /'

    if echo "$MOUNTS" | grep -q "/var/run/docker.sock"; then
        fail "Docker socket /var/run/docker.sock IS mounted in sandbox container!"
    else
        pass "Docker socket /var/run/docker.sock is NOT mounted"
    fi

    # Host root mount check
    if echo "$MOUNTS" | grep -E '^/ ->|^/host|^Source: / '; then
        fail "Dangerous host root / mounted in container"
    else
        pass "Host root / is NOT mounted in container"
    fi
else
    fail "No running Qwen sandbox container found"
fi

# 3. Systemd service sandbox drop-in
ENV_DROPIN=$(systemctl show nwa-qwen.service -p Environment 2>/dev/null || true)
if echo "$ENV_DROPIN" | grep -q "QWEN_SANDBOX=docker"; then
    pass "nwa-qwen.service has QWEN_SANDBOX=docker drop-in active"
else
    fail "nwa-qwen.service missing QWEN_SANDBOX=docker"
fi

# 4. Disposable fail-closed container test (Simulating isolated sandbox boundaries)
info "Running disposable hardened container isolation test..."
TEST_OUT=$(sudo docker run --rm \
    --network none \
    --read-only \
    --security-opt no-new-privileges:true \
    --cap-drop ALL \
    "$QIMG" \
    sh -c '
        test ! -e /var/run/docker.sock && echo DOCKER_SOCKET_ABSENT
        (touch /escape_test >/dev/null 2>&1 && echo WRITE_ALLOWED) || echo ROOTFS_WRITE_BLOCKED
    ' 2>&1)

if echo "$TEST_OUT" | grep -q "DOCKER_SOCKET_ABSENT"; then
    pass "Isolated execution: Docker socket absent inside container"
else
    fail "Isolated execution: Docker socket test failed"
fi

if echo "$TEST_OUT" | grep -q "ROOTFS_WRITE_BLOCKED"; then
    pass "Fail-closed check: Read-only container rootfs blocks unauthorized file writes"
else
    fail "Fail-closed check: Container rootfs was writeable"
fi

echo "----------------------------------------------"
echo "TASK 1 RESULT: $PASS_COUNT PASSED, $FAIL_COUNT FAILED"
echo "----------------------------------------------"
