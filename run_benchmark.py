import urllib.request
import json
import time
import concurrent.futures
import statistics

BASE_URL = 'http://100.69.96.57:8080/v1'
MODEL = 'qwen3.8-27b-nvfp4'

def stream_request(prompt, max_tokens=256, temp=0.7):
    url = f"{BASE_URL}/chat/completions"
    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": temp,
        "stream": True
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={"Content-Type": "application/json"})
    
    t_start = time.perf_counter()
    t_first = None
    token_count = 0
    full_content = []
    
    with urllib.request.urlopen(req, timeout=120) as resp:
        for raw_line in resp:
            line = raw_line.decode('utf-8').strip()
            if not line or line == 'data: [DONE]':
                continue
            if line.startswith('data: '):
                try:
                    obj = json.loads(line[6:])
                    delta = obj['choices'][0]['delta']
                    c = delta.get('content', '') or delta.get('reasoning_content', '')
                    if c:
                        if t_first is None:
                            t_first = time.perf_counter()
                        token_count += 1
                        full_content.append(c)
                except Exception:
                    pass
    t_end = time.perf_counter()
    ttft = (t_first - t_start) if t_first else (t_end - t_start)
    gen_time = (t_end - t_first) if (t_first and t_end > t_first) else 0.001
    speed = token_count / gen_time if gen_time > 0 else 0
    return {
        "ttft_ms": round(ttft * 1000, 2),
        "tokens": token_count,
        "gen_time_s": round(gen_time, 3),
        "tokens_per_sec": round(speed, 2),
        "total_time_s": round(t_end - t_start, 3),
        "response_preview": "".join(full_content)[:250]
    }

def non_stream_request(prompt, max_tokens=16):
    url = f"{BASE_URL}/chat/completions"
    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": 0.0,
        "stream": False
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={"Content-Type": "application/json"})
    t_start = time.perf_counter()
    with urllib.request.urlopen(req, timeout=180) as resp:
        res = json.loads(resp.read().decode('utf-8'))
    t_end = time.perf_counter()
    
    usage = res.get('usage', {})
    prompt_tokens = usage.get('prompt_tokens', 0)
    total_time = t_end - t_start
    prefill_speed = prompt_tokens / total_time if total_time > 0 else 0
    return {
        "prompt_tokens": prompt_tokens,
        "latency_s": round(total_time, 3),
        "prefill_tokens_per_sec": round(prefill_speed, 2)
    }

print("=== 1. TTFT & Generation Speed (5 Runs) ===")
ttft_list = []
tps_list = []
test_prompt = "Write a comprehensive Python implementation of a Thread-Safe LRU Cache with TTL."
for i in range(5):
    res = stream_request(test_prompt, max_tokens=300)
    ttft_list.append(res['ttft_ms'])
    tps_list.append(res['tokens_per_sec'])
    print(f"  Run {i+1}: TTFT = {res['ttft_ms']} ms | Tokens = {res['tokens']} | Output Speed = {res['tokens_per_sec']} tok/s")

print(f"  --> Average TTFT: {statistics.mean(ttft_list):.2f} ms")
print(f"  --> Average Generation Speed: {statistics.mean(tps_list):.2f} tokens/sec")

print("\n=== 2. Prompt / Prefill Throughput ===")
for char_len in [2000, 8000, 24000]:
    sample_text = "Blackwell architecture features 5th-generation Tensor Cores with native FP4 precision micro-scaling. " * (char_len // 100)
    p = f"Summarize the core technical advantages described in this document in two bullet points:\n\n{sample_text}"
    pf_res = non_stream_request(p, max_tokens=10)
    print(f"  Prompt Tokens: {pf_res['prompt_tokens']} | Latency: {pf_res['latency_s']}s | Prefill Speed: {pf_res['prefill_tokens_per_sec']} tok/s")

print("\n=== 3. Concurrency Benchmark (4 Simultaneous Streams) ===")
t_start = time.perf_counter()
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    futures = [executor.submit(stream_request, f"Explain the principles and tradeoffs of distributed computing paradigm #{i+1}.", 200) for i in range(4)]
    results = [f.result() for f in futures]
t_end = time.perf_counter()
total_tokens = sum(r['tokens'] for r in results)
agg_tps = total_tokens / (t_end - t_start)
print(f"  4 Concurrent Streams: {total_tokens} total tokens in {t_end - t_start:.2f}s | Aggregate: {agg_tps:.2f} tok/s")
for idx, r in enumerate(results):
    print(f"    Stream {idx+1}: TTFT = {r['ttft_ms']} ms | Speed = {r['tokens_per_sec']} tok/s")

print("\n=== 4. Quality & Reasoning Check (NVFP4 Precision Integrity) ===")
reasoning_prompts = [
    "Solve step by step: A bat and a ball cost $1.10 in total. The bat costs $1.00 more than the ball. How much does the ball cost?",
    "Identify the bug: def is_prime(n):\n    if n < 2: return False\n    for i in range(2, int(n**0.5)):\n        if n % i == 0: return False\n    return True\nExplain what numbers fail and how to fix it."
]
for p in reasoning_prompts:
    res = stream_request(p, max_tokens=300)
    print(f"  Prompt: {p[:65]}...")
    print(f"  Preview: {res['response_preview'][:200]}...\n")

print("=== Benchmark Suite Completed Successfully ===")
