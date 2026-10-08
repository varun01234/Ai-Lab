import paramiko
import sys

paramiko.util.log_to_file('/tmp/paramiko.log')

host = '100.69.96.57'
user = 'aiadmin1'
password = 'AIadmin2026!'

t = paramiko.Transport((host, 22))
t.connect()

def h(title, instructions, prompts):
    print(f"PROMPTS RECEIVED: {prompts}")
    return [password for _ in prompts]

try:
    print(f"Starting auth_interactive for {user}...")
    t.auth_interactive(user, h)
    print("Is authenticated:", t.is_authenticated())
except Exception as e:
    print(f"Auth exception: {type(e).__name__}: {e}")
finally:
    t.close()

with open('/tmp/paramiko.log') as f:
    for line in f.readlines()[-20:]:
        print("LOG:", line.strip())
