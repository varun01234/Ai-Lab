import json

p = '/srv/nwa/workspaces/.qwen/settings.json'
with open(p) as f:
    d = json.load(f)

d.setdefault('mcpServers', {}).setdefault('memory', {})['env'] = {
    'MEMORY_FILE_PATH': '/srv/nwa/workspaces/memory/memory.json'
}

with open(p, 'w') as f:
    json.dump(d, f, indent=2)

print("SETTINGS_UPDATED_SUCCESS")
