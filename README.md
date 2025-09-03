# lesson-3

Short instructions:

1) Prepare env
```zsh
./install_dev_tools.sh
source .venv/bin/activate
```
# lesson-3 — quick start (no drama)

All commands assume you're in the project root and have zsh.

1) Create venv and install deps

```zsh
./install_dev_tools.sh
source .venv/bin/activate
```

2) Export the TorchScript model (creates model.pt)

```zsh
.venv/bin/python export_model.py
```

3) Run inference locally

```zsh
.venv/bin/python inference.py images/kieran-white-NKN25UfGfkQ-unsplash.jpg
```

4) Build Docker images (use classic builder if BuildKit hangs on macOS)

```zsh
# If buildkit has issues on macOS, prefix with DOCKER_BUILDKIT=0
DOCKER_BUILDKIT=0 docker build -f Dockerfile.fat -t mobilenet-fat:latest .
DOCKER_BUILDKIT=0 docker build -f Dockerfile.slim -t mobilenet-slim:latest .
```

5) Run containers (mount repo so they use current files)

```zsh
# runs inference.py inside the container using the mounted /app
docker run --rm -v "$PWD":/app mobilenet-fat:latest python /app/inference.py /app/images/kieran-white-NKN25UfGfkQ-unsplash.jpg
docker run --rm -v "$PWD":/app mobilenet-slim:latest python /app/inference.py /app/images/kieran-white-NKN25UfGfkQ-unsplash.jpg
```

Notes:
- If you get a `PytorchStreamReader failed reading zip archive` error, re-run the export step inside the venv to regenerate `model.pt`.
- There's a `test_results.txt` with prior container outputs. I didn't commit it; commit if you want.
