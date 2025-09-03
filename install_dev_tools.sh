#!/usr/bin/env bash
set -euo pipefail

LOG="install.log"
echo "=== install_dev_tools.sh start: $(date) ===" | tee -a "$LOG"

have() { command -v "$1" >/dev/null 2>&1; }

PY_CMD=""
if have python3; then
  PY_CMD=python3
elif have python; then
  PY_CMD=python
else
  echo "No python binary found in PATH. Please install Python >= 3.9 manually." | tee -a "$LOG"
  exit 1
fi

printf "Using python: %s\n" "$( $PY_CMD --version 2>&1 )" | tee -a "$LOG"

# Respect already-activated virtual environment
if [ -n "${VIRTUAL_ENV:-}" ]; then
  echo "Detected active virtualenv: $VIRTUAL_ENV" | tee -a "$LOG"
  PIP="$VIRTUAL_ENV/bin/pip"
  PYEXEC="$VIRTUAL_ENV/bin/python"
else
  # create local .venv if missing
  if [ ! -d ".venv" ]; then
    echo "Creating virtualenv at ./.venv" | tee -a "$LOG"
    $PY_CMD -m venv .venv
  else
    echo "Using existing .venv" | tee -a "$LOG"
  fi
  PYEXEC="./.venv/bin/python"
  PIP="./.venv/bin/pip"
fi

echo "Upgrading pip/setuptools/wheel in $PYEXEC" | tee -a "$LOG"
$PYEXEC -m pip install --upgrade pip setuptools wheel 2>&1 | tee -a "$LOG"

echo "Ensuring required Python packages are installed in the venv" | tee -a "$LOG"
PKGS=(torch torchvision pillow django matplotlib)
for pkg in "${PKGS[@]}"; do
  # quick import check
  if ! $PYEXEC -c "import importlib,sys
spec = importlib.util.find_spec(\"$pkg\")
sys.exit(0 if spec else 1)" 2>/dev/null; then
    echo "Installing $pkg" | tee -a "$LOG"
    $PIP install "$pkg" 2>&1 | tee -a "$LOG" || {
      echo "Failed to pip install $pkg (see above). Continuing..." | tee -a "$LOG"
    }
  else
    echo "$pkg already installed" | tee -a "$LOG"
  fi
done

echo "Checking Docker / Docker Compose presence" | tee -a "$LOG"
if have docker; then
  echo "docker: $(docker --version 2>&1)" | tee -a "$LOG"
else
  echo "Docker not found." | tee -a "$LOG"
  # Try best-effort hints for Linux/brew (non-destructive)
  if have apt-get; then
    echo "On Debian/Ubuntu: sudo apt-get update && sudo apt-get install -y docker.io docker-compose" | tee -a "$LOG"
  elif have brew; then
    echo "On macOS with Homebrew: brew install --cask docker  (you must start Docker Desktop after install)" | tee -a "$LOG"
    # try brew install (best-effort)
    if have brew; then
      brew install --cask docker 2>&1 | tee -a "$LOG" || true
    fi
  fi
fi

echo "Summary of versions:" | tee -a "$LOG"
docker --version 2>>"$LOG" || echo "docker: not available" | tee -a "$LOG"
docker compose version 2>>"$LOG" || true
$PYEXEC --version 2>&1 | tee -a "$LOG"
$PIP --version 2>&1 | tee -a "$LOG"

echo "=== install_dev_tools.sh end: $(date) ===" | tee -a "$LOG"

cat <<'USAGE'
Done. To start using the virtual environment:
  source .venv/bin/activate
Then run your Python scripts with 'python' or './.venv/bin/python'.
Logs were appended to install.log
USAGE

exit 0
