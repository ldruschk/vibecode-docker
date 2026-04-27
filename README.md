# vibecode-docker

Arch Linux based Docker image for the [Opencode CLI](https://github.com/anomalyco/opencode) with DevOps tooling.

> This project was vibecoded entirely with [opencode](https://opencode.ai).

## Usage

### docker-compose.yml (example)

```yaml
services:
  vibecode:
    image: ghcr.io/ldruschk/vibecode-docker:latest
    container_name: vibecode
    working_dir: /workspace
    volumes:
      - .:/workspace
      - /home/lucas/.local/share/opencode:/home/vibecode/.local/share/opencode
      - /home/lucas/.local/state/opencode:/home/vibecode/.local/state/opencode
    environment:
      - TERM=${TERM:-xterm-256color}
      - COLORTERM=${COLORTERM:-truecolor}
    stdin_open: true
    tty: true
```

### .gitignore (example)

```gitignore
.credentials/
```

## Credentials

Place SSH keys, kube-configs, and other credentials in `.credentials/` at the project root. This folder is excluded from Git.

## Run

Start an interactive opencode session from your VS Code terminal:

```bash
docker compose run --rm vibecode opencode
```

This mounts your current project directory, makes `.credentials/` available, and launches opencode inside the container with persisted auth and sessions. Exit with Ctrl+C to stop and remove the container.

## Build

```bash
docker build -t ghcr.io/ldruschk/vibecode-docker:latest .
```

## Included Tools

- **Opencode CLI** — AI coding agent
- **Crane** — Container registry tooling
- **Kubectl, Helm, Kustomize** — Kubernetes toolchain
- **Git, GitHub CLI** — Version control
- **Node.js, Python, Go** — Language runtimes
- **jq, yq, ripgrep, fzf, tmux, vim** — Developer utilities
