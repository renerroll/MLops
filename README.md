# lesson-3

Short instructions:

1) Prepare env
```zsh
./install_dev_tools.sh
source .venv/bin/activate
```

2) Export model
```zsh
./.venv/bin/python export_model.py
```

3) Run inference
```zsh
./.venv/bin/python inference.py images/dog_test.jpg
```

4) Build images
```zsh
DOCKER_BUILDKIT=0 docker build -f Dockerfile.fat -t mobilenet-fat:latest .
DOCKER_BUILDKIT=0 docker build -f Dockerfile.slim -t mobilenet-slim:latest .
```
