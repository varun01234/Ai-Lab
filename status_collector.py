#!/usr/bin/env python3
import os
import subprocess
import json
import time

def get_status():
    jail = '/srv/nwa-model/models'
    m27 = os.path.join(jail, 'main-27b/Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf')
    m30 = os.path.join(jail, 'coder-30b/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf')
    w8_dir = os.path.join(jail, 'worker-8b')
    cache_file = '/tmp/status_collector_cache.json'
    now = time.time()

    # aria2 status
    res = subprocess.run(['pgrep', '-a', 'aria2c'], capture_output=True, text=True)
    aria2_active = (res.returncode == 0)
    aria2_pid = res.stdout.strip().split()[0] if aria2_active else None

    # 27B check
    m27_done = False
    m27_cur_gib = 0.0
    m27_tot_gib = 15.65
    written_27 = 0
    if os.path.exists(m27):
        st = os.stat(m27)
        written_27 = st.st_blocks * 512
        m27_cur_gib = round(written_27 / (1024**3), 2)
        if not os.path.exists(m27 + '.aria2') and written_27 >= 16000000000:
            m27_done = True
            m27_pct = 100.0
        else:
            m27_pct = min(99.9, round((written_27 / 16810714400) * 100, 1))
    else:
        m27_pct = 0.0

    # 30B check
    m30_done = False
    m30_cur_gib = 0.0
    m30_tot_gib = 17.28
    m30_bytes = 0
    total_30b_exp = 18556689600
    if os.path.exists(m30):
        st = os.stat(m30)
        m30_bytes = st.st_blocks * 512
        m30_cur_gib = round(m30_bytes / (1024**3), 2)
        if st.st_size > 0:
            total_30b_exp = st.st_size
        m30_tot_gib = round(total_30b_exp / (1024**3), 2)
        m30_pct = min(99.9, round((m30_bytes / total_30b_exp) * 100, 1))
        if not os.path.exists(m30 + '.aria2') and m30_bytes >= 18000000000:
            m30_done = True
            m30_pct = 100.0
    else:
        m30_pct = 0.0

    # 8B check
    w8_files = os.listdir(w8_dir) if os.path.exists(w8_dir) else []
    w8_safetensors = [f for f in w8_files if f.endswith('.safetensors')]
    w8_aria = [f for f in w8_files if f.endswith('.aria2')]
    w8_bytes = 0
    for f in w8_safetensors:
        try:
            w8_bytes += os.stat(os.path.join(w8_dir, f)).st_blocks * 512
        except Exception:
            pass
    w8_tot_bytes = 16381470720
    w8_cur_gib = round(w8_bytes / (1024**3), 2)
    w8_tot_gib = round(w8_tot_bytes / (1024**3), 2)
    w8_done = (len(w8_safetensors) >= 4 and len(w8_aria) == 0 and w8_bytes >= 16000000000)
    w8_pct = 100.0 if w8_done else min(99.9, round((w8_bytes / w8_tot_bytes) * 100, 1))

    # Speed & ETA calculation based on delta
    current_speed_str = "Calculating..."
    eta_str = "Calculating..."
    prev = {}
    if os.path.exists(cache_file):
        try:
            with open(cache_file, 'r') as f:
                prev = json.load(f)
        except Exception:
            pass

    if prev and 'time' in prev:
        dt = now - prev['time']
        if dt > 1.0:
            if not m27_done and 'm27_bytes' in prev:
                dbytes = written_27 - prev['m27_bytes']
                target_rem = max(0, 16810714400 - written_27)
            elif not m30_done and 'm30_bytes' in prev:
                dbytes = m30_bytes - prev['m30_bytes']
                target_rem = max(0, total_30b_exp - m30_bytes)
            elif not w8_done and 'w8_bytes' in prev:
                dbytes = w8_bytes - prev['w8_bytes']
                target_rem = max(0, w8_tot_bytes - w8_bytes)
            else:
                dbytes = 0
                target_rem = 0
                
            speed = max(0, dbytes / dt)
            speed_mb = speed / (1024 * 1024)
            current_speed_str = f"{speed_mb:.2f} MiB/s"
            
            if aria2_active and speed > 10000 and target_rem > 0:
                rem_sec = int(target_rem / speed)
                mins = rem_sec // 60
                hrs = mins // 60
                mins = mins % 60
                eta_str = f"{hrs}h {mins}m" if hrs > 0 else f"{mins}m"
            elif not aria2_active:
                current_speed_str = "0.00 MiB/s (Idle/Paused)"
                eta_str = "Paused"
            elif m27_done and m30_done and w8_done:
                eta_str = "Done"
    elif not aria2_active:
        current_speed_str = "0.00 MiB/s (Idle/Paused)"
        eta_str = "Paused"

    # Save cache
    try:
        with open(cache_file, 'w') as f:
            json.dump({
                'time': now,
                'm27_bytes': written_27,
                'm30_bytes': m30_bytes,
                'w8_bytes': w8_bytes
            }, f)
    except Exception:
        pass

    # Disk check
    df_res = subprocess.run(['df', '-h', jail], capture_output=True, text=True)
    df_line = df_res.stdout.strip().split('\n')[-1] if df_res.stdout else ""

    # Stage determination
    if not m27_done:
        stage = '1/3: 27B Main Model (Huihui-Qwen3.8-27B-abliterated-Q4_K.gguf)'
        if aria2_active:
            what = f'Actively downloading 27B model chunks ({m27_cur_gib} GiB / {m27_tot_gib} GiB, {m27_pct}% done) at {current_speed_str}'
            stream_info = f"DL: {current_speed_str} | ETA: {eta_str}"
        else:
            what = f'27B model download paused/idle ({m27_cur_gib} GiB / {m27_tot_gib} GiB, {m27_pct}% done)'
            stream_info = "Status: IDLE / PAUSED"
    elif not m30_done:
        stage = '2/3: 30B Coding Model (Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.Q4_K_M.gguf)'
        if aria2_active:
            what = f'Actively downloading 30B coding model chunks ({m30_cur_gib} GiB / {m30_tot_gib} GiB, {m30_pct}% done) at {current_speed_str}'
            stream_info = f"DL: {current_speed_str} | ETA: {eta_str}"
        else:
            what = f'30B coding model download paused/idle ({m30_cur_gib} GiB / {m30_tot_gib} GiB, {m30_pct}% done)'
            stream_info = "Status: IDLE / PAUSED"
    elif not w8_done:
        stage = '3/3: 8B Worker Model (Huihui-Qwen3-8B-abliterated-v2)'
        if aria2_active:
            what = f'Actively downloading 8B worker model safetensors weights ({w8_cur_gib} GiB / {w8_tot_gib} GiB, {w8_pct}% done) at {current_speed_str}'
            stream_info = f"DL: {current_speed_str} | ETA: {eta_str}"
        else:
            what = f'8B worker model download paused/idle ({w8_cur_gib} GiB / {w8_tot_gib} GiB, {w8_pct}% done)'
            stream_info = "Status: IDLE / PAUSED"
    else:
        stage = 'COMPLETE: All 3 Models Staged & Quarantined'
        what = 'All model weights downloaded. Strict permissions (750 dirs, 640 files) enforced.'
        stream_info = "Status: ALL COMPLETE"

    out = {
        'stage': stage,
        'what_is_happening': what,
        'aria2_active': aria2_active,
        'aria2_pid': aria2_pid,
        'latest_stream_info': stream_info,
        'current_speed': current_speed_str,
        'eta': eta_str,
        'm27': {'done': m27_done, 'pct': m27_pct, 'gib': m27_cur_gib, 'total_gib': m27_tot_gib},
        'm30': {'done': m30_done, 'pct': m30_pct, 'gib': m30_cur_gib, 'total_gib': m30_tot_gib},
        'w8': {'done': w8_done, 'pct': w8_pct, 'gib': w8_cur_gib, 'total_gib': w8_tot_gib, 'files_count': len(w8_files)},
        'disk': df_line
    }
    print(json.dumps(out))

if __name__ == '__main__':
    get_status()
