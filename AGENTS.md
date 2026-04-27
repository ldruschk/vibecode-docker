# AGENTS.md

## Project Overview

`vibecode-docker` provides an Arch Linux based Docker image for the Opencode CLI with DevOps tooling (kubectl, helm, kustomize, crane, gh, etc.). The image is published at `ghcr.io/ldruschk/vibecode-docker`.

## Key Files

| File | Purpose |
|---|---|
| `Dockerfile` | Image definition — Arch base, package install, opencode+crane binaries |
| `README.md` | Usage examples (docker-compose, gitignore) |
| `.github/workflows/main.yml` | CI/CD — builds and pushes to ghcr.io |
| `AI-CHANGELOG.md` | Record of AI-assisted changes |

## Build & Run

```bash
docker build -t ghcr.io/ldruschk/vibecode-docker:latest .
docker compose run --rm vibecode opencode
```

## Image Details

- **Base**: `archlinux:latest`
- **User**: `vibecode` (non-root, passwordless sudo via wheel group)
- **Workdir**: `/workspace`
- **opencode**: installed to `/usr/local/bin/opencode` via official install script
- **crane**: downloaded from `google/go-containerregistry` releases to `/usr/local/bin/crane`
