# Report — Docker image comparison and recommendations

This project contains two Docker images built from the same codebase and a TorchScript `model.pt`:

- mobilenet-fat: single-stage image, includes build tools and full Python environment
- mobilenet-slim: multi-stage image that copies only runtime files from a builder stage

## Measured results

- mobilenet-fat: ~2.69 GB, 20 layers
- mobilenet-slim: ~1.28 GB, 16 layers

> Numbers measured on macOS host with Docker Desktop; reported sizes are the image sizes visible via `docker images` after building with `DOCKER_BUILDKIT=0`.

## Observations

- The slim image is roughly half the size of the fat image due to removal of build dependencies and unused files.
- Both images run the same TorchScript model and produce consistent top-3 predictions for test images in `images/`.

## Recommendations

1. Keep the `model.pt` artifact outside the image and download it at container start time if you want to make images even smaller and enable model swapping.
2. Use CPU-only PyTorch wheels (or manylinux2014 wheels) targeted for the final architecture to avoid carrying build caches.
3. Consider distroless or Alpine-based final stage images if you can satisfy binary dependencies (PyTorch binaries can be tricky on musl).
4. If reproducible builds are required, pin Python and pip package versions in `requirements.txt`.

## Next steps (optional)

- Implement runtime model download and verification.
- Use `docker-slim` or `strip`/`del` unused shared libraries to further reduce size.
- Replace numeric indices with human-readable labels in `inference.py` (already implemented using `imagenet_classes.txt`).

## Sample inference outputs (final runs)

- kieran-white-NKN25UfGfkQ-unsplash.jpg
	- mobilenet-fat:
		- 1. Eskimo dog — 29.11% (id=248)
		- 2. Siberian husky — 14.06% (id=250)
		- 3. malamute — 4.57% (id=249)
	- mobilenet-slim:
		- 1. Eskimo dog — 29.11% (id=248)
		- 2. Siberian husky — 14.06% (id=250)
		- 3. malamute — 4.57% (id=249)

- timo-volz-ZlFKIG6dApg-unsplash.jpg
	- mobilenet-fat:
		- 1. Egyptian cat — 9.50% (id=285)
		- 2. tiger cat — 5.49% (id=282)
		- 3. tabby — 4.74% (id=281)
	- mobilenet-slim:
		- 1. Egyptian cat — 9.50% (id=285)
		- 2. tiger cat — 5.49% (id=282)
		- 3. tabby — 4.74% (id=281)

## Task checklist mapping

- Ran both images on sample inputs: Done (outputs above).
- Image sizes: recorded earlier (mobilenet-fat ~2.69GB, mobilenet-slim ~1.28GB).
- Layer counts: recorded earlier (fat: 20, slim: 16) — see `docker history` outputs.
- Presence of extra tools: `mobilenet-fat` includes `build-essential` and full pip-installed packages; `mobilenet-slim` minimizes runtime packages via multi-stage build.
- Optimization suggestions: listed in Recommendations section above.

