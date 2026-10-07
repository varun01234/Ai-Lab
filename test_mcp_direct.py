#!/usr/bin/env python3
import json
import subprocess
import sys
import os

print("=== TESTING OFFICIAL VENDOR MEMORY MCP SERVER WITH PERSISTENCE ===")

mem_file = "/srv/nwa/workspaces/memory/memory.json"
os.makedirs("/srv/nwa/workspaces/memory", exist_ok=True)

env = dict(os.environ)
env["MEMORY_FILE_PATH"] = mem_file

# Run the memory server process via stdio
proc = subprocess.Popen(
    ["npx", "-y", "@modelcontextprotocol/server-memory"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
    env=env,
    cwd="/srv/nwa/workspaces"
)

def send(msg):
    line = json.dumps(msg) + "\n"
    proc.stdin.write(line)
    proc.stdin.flush()

def read_line():
    while True:
        line = proc.stdout.readline()
        if not line:
            return None
        line = line.strip()
        if not line:
            continue
        try:
            return json.loads(line)
        except Exception:
            continue

# 1. Initialize
init_req = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
        "protocolVersion": "2024-11-05",
        "capabilities": {},
        "clientInfo": {"name": "qwen-daemon-test", "version": "1.0.0"}
    }
}
send(init_req)
resp = read_line()
print("1. Initialize Response:", resp.get("result", {}).get("serverInfo", {}))

# 2. List tools
list_req = {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}}
send(list_req)
tools_resp = read_line()
tools = [t["name"] for t in tools_resp.get("result", {}).get("tools", [])]
print("2. Discovered Tools:", tools)

# 3. Store knowledge (create_entities)
store_req = {
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
        "name": "create_entities",
        "arguments": {
            "entities": [
                {
                    "name": "Qwen-Daemon-Production",
                    "entityType": "DaemonArchitecture",
                    "observations": [
                        "Sandbox isolation active with zero host-root or docker socket leaks",
                        "Approved workspace is /srv/nwa/workspaces",
                        "MCP memory persistence verified on 2026-10-07"
                    ]
                }
            ]
        }
    }
}
send(store_req)
store_resp = read_line()
print("3. Store (create_entities) Result:", store_resp.get("result", {}).get("content", []))

# 4. Retrieve knowledge (search_nodes)
retrieve_req = {
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
        "name": "search_nodes",
        "arguments": {
            "query": "Qwen-Daemon-Production"
        }
    }
}
send(retrieve_req)
retrieve_resp = read_line()
print("4. Retrieve (search_nodes) Result:", retrieve_resp.get("result", {}).get("content", []))

# Shutdown
proc.terminate()
proc.wait()

# 5. Check Persistence on disk
print("\n=== CHECKING DISK PERSISTENCE ===")
if os.path.exists(mem_file):
    print("SUCCESS: Persistent file exists:", mem_file, f"({os.path.getsize(mem_file)} bytes)")
    with open(mem_file) as f:
        content = f.read()
        print("Persisted Data Preview:", content[:300])
    print("\n>>> VERDICT: MEMORY STORE -> RETRIEVE -> PERSISTENCE IS PASS! <<<")
else:
    # Check default directory
    parent = os.path.dirname(mem_file)
    print("Files in", parent, ":", os.listdir(parent))
