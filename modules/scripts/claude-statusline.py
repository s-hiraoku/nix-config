#!/usr/bin/env python3
"""Claude Code statusline — simple text, gradient on meters only"""
import json, sys, subprocess, os, time

data = json.load(sys.stdin)

R = '\033[0m'
DIM = '\033[38;2;140;140;140m'
BOLD = '\033[1m'
WHITE = '\033[37m'

# ── Ring meter ──────────────────────────────────
RINGS = ['○', '◔', '◑', '◕', '●']

def gradient(pct):
    """Green → Yellow → Red gradient based on percentage"""
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def ring(pct):
    return RINGS[min(int(pct / 25), 4)]

def fmt_ring(label, pct):
    """Label in dim white, ring + percentage in gradient color"""
    p = round(pct)
    c = gradient(pct)
    return f'{DIM}{label}{R} {c}{ring(pct)} {p}%{R}'

SEP = f' {DIM}│{R} '

def parse_reset(v):
    """resets_at を epoch 秒に変換 (epoch数値 / ISO文字列 両対応)"""
    if v is None:
        return None
    if isinstance(v, (int, float)):
        return float(v)
    try:
        from datetime import datetime
        return datetime.fromisoformat(str(v).replace('Z', '+00:00')).timestamp()
    except Exception:
        return None

def limit_reset(info):
    """レートリミットのリセット時刻を表示 (24h以内は時刻、以降は日付)"""
    reset = parse_reset(info.get('resets_at') or info.get('reset_at') or info.get('resets'))
    if reset is None:
        return ''
    from datetime import datetime
    dt = datetime.fromtimestamp(reset)
    if reset - time.time() < 24 * 3600:
        return f' {DIM}↻{dt.strftime("%H:%M")}{R}'
    return f' {DIM}↻{dt.month}/{dt.day}{R}'

# ── Git branch (cached per directory) ───────────
import hashlib
cwd = (data.get('cwd') or
       data.get('workspace', {}).get('current_dir') or
       data.get('workspace', {}).get('project_dir') or
       '')
cwd_hash = hashlib.md5(cwd.encode()).hexdigest()[:8]
GIT_CACHE = f'/tmp/claude-statusline-git-{cwd_hash}'
GIT_CACHE_AGE = 5
refresh = True
if os.path.exists(GIT_CACHE):
    age = time.time() - os.path.getmtime(GIT_CACHE)
    if age <= GIT_CACHE_AGE:
        refresh = False

if refresh:
    try:
        subprocess.check_output(['git', 'rev-parse', '--git-dir'], stderr=subprocess.DEVNULL, cwd=cwd or None)
        branch = subprocess.check_output(['git', 'branch', '--show-current'], text=True, stderr=subprocess.DEVNULL, cwd=cwd or None).strip()
        staged = subprocess.check_output(['git', 'diff', '--cached', '--numstat'], text=True, stderr=subprocess.DEVNULL, cwd=cwd or None).strip()
        modified = subprocess.check_output(['git', 'diff', '--numstat'], text=True, stderr=subprocess.DEVNULL, cwd=cwd or None).strip()
        staged_n = len(staged.split('\n')) if staged else 0
        modified_n = len(modified.split('\n')) if modified else 0
        with open(GIT_CACHE, 'w') as f:
            f.write(f'{branch}|{staged_n}|{modified_n}')
    except Exception:
        # git リポジトリが見つからない場合はキャッシュを作らず既存キャッシュも削除
        if os.path.exists(GIT_CACHE):
            os.remove(GIT_CACHE)

try:
    with open(GIT_CACHE) as f:
        parts = f.read().strip().split('|')
        branch = parts[0] if len(parts) > 0 else ''
        staged_n = parts[1] if len(parts) > 1 else ''
        modified_n = parts[2] if len(parts) > 2 else ''
except Exception:
    branch, staged_n, modified_n = '', '', ''

# ══════════════════════════════════════════════════
# LINE 1: Model | Session ID | Git Branch + Changes
# ══════════════════════════════════════════════════
model = data.get('model', {}).get('display_name', 'Claude')
line1 = [f'{WHITE}{BOLD}\U000f0e51 {model}{R}']

sid = data.get('session_id', '')
if sid:
    line1.append(f'{DIM}\uf4fe {sid[:8]}{R}')

if branch:
    git_str = f'{WHITE}\ue725 {branch}{R}'
    chg = []
    if staged_n and int(staged_n) > 0:
        chg.append(f'+{staged_n}')
    if modified_n and int(modified_n) > 0:
        chg.append(f'~{modified_n}')
    if chg:
        git_str += f' {DIM}{" ".join(chg)}{R}'
    line1.append(git_str)

print(SEP.join(line1))

# ══════════════════════════════════════════════════
# LINE 2: Context | 5h rate limit | 7d rate limit
# ══════════════════════════════════════════════════
line2 = []

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    ctx_size = data.get('context_window', {}).get('context_window_size', 0)
    size_str = f' {ctx_size // 1000}k' if ctx_size > 0 else ''
    line2.append(fmt_ring(f'\uf0c9 ctx{size_str}', ctx))

five_info = data.get('rate_limits', {}).get('five_hour', {})
five = five_info.get('used_percentage')
if five is not None:
    line2.append(fmt_ring('\uf253 5h', five) + limit_reset(five_info))

week_info = data.get('rate_limits', {}).get('seven_day', {})
week = week_info.get('used_percentage')
if week is not None:
    line2.append(fmt_ring('\uf073 7d', week) + limit_reset(week_info))

if line2:
    print(SEP.join(line2), end='')

