#!/usr/bin/env bash
# env-check.sh — CS research environment audit
# Run on the target Linux machine. Read-only: collects info, changes nothing.
# Usage: bash env-check.sh | tee env-check-$(date +%Y%m%d).log

set -u

section() { printf '\n========== %s ==========\n' "$1"; }
kv() { printf '%-24s %s\n' "$1" "$2"; }

section "System"
kv "hostname" "$(hostname 2>/dev/null)"
kv "os" "$( (cat /etc/os-release 2>/dev/null | grep '^PRETTY_NAME=' | cut -d= -f2- | tr -d '"') || uname -s )"
kv "kernel" "$(uname -r)"
kv "arch" "$(uname -m)"
kv "uptime" "$(uptime -p 2>/dev/null || uptime)"

section "CPU / Memory"
kv "cpu model" "$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //')"
kv "cpu cores" "$(nproc 2>/dev/null)"
if command -v free >/dev/null 2>&1; then
  free -h | awk 'NR==1||NR==2'
fi

section "GPU"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.used,utilization.gpu \
    --format=csv,noheader 2>/dev/null
  kv "cuda (driver api)" "$(nvidia-smi 2>/dev/null | grep -m1 'CUDA Version' | sed 's/.*CUDA Version: *//;s/ .*//')"
else
  echo "nvidia-smi not found: no NVIDIA GPU or driver not installed"
fi
if command -v nvcc >/dev/null 2>&1; then
  kv "nvcc" "$(nvcc --version 2>/dev/null | grep release | sed 's/,.*//')"
else
  kv "nvcc" "not found (CUDA toolkit not on PATH)"
fi

section "Python / Package Managers"
for py in python3 python; do
  if command -v "$py" >/dev/null 2>&1; then
    kv "$py" "$($py --version 2>&1) ($(command -v $py))"
  fi
done
for pm in conda mamba pip3 uv docker git; do
  if command -v "$pm" >/dev/null 2>&1; then
    kv "$pm" "$($pm --version 2>&1 | head -n1)"
  else
    kv "$pm" "not found"
  fi
done

section "Deep Learning Frameworks"
python3 - <<'EOF' 2>/dev/null || echo "python3 probe skipped"
import importlib
for mod in ["torch", "tensorflow", "jax", "transformers", "numpy"]:
    try:
        m = importlib.import_module(mod)
        ver = getattr(m, "__version__", "?")
        extra = ""
        if mod == "torch":
            extra = f" cuda_available={m.cuda.is_available()} torch_cuda={m.version.cuda}"
        print(f"{mod:14s} {ver}{extra}")
    except ImportError:
        print(f"{mod:14s} not installed")
EOF

section "Disk"
df -h / "$HOME" 2>/dev/null | sort -u

section "Network"
if command -v curl >/dev/null 2>&1; then
  for url in https://pypi.org https://arxiv.org https://huggingface.co; do
    code=$(curl -o /dev/null -s -m 8 -w '%{http_code}' "$url" || echo "FAIL")
    kv "$url" "$code"
  done
else
  echo "curl not found; skipped"
fi

section "Conda Envs"
if command -v conda >/dev/null 2>&1; then
  conda env list 2>/dev/null
else
  echo "conda not found"
fi

section "Summary Hints"
echo "- If GPU missing but hardware exists: check driver install (needs sudo, human confirms)."
echo "- If frameworks missing: create a dedicated conda env; do NOT pip-install into system python."
echo "- Save this log alongside your experiment for reproducibility."
