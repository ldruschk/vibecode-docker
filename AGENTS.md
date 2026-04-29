# AGENTS.md

## Project Overview

`vibecode-docker` provides an Arch Linux based Docker image for the Opencode CLI with DevOps tooling (kubectl, helm, kustomize, crane, gh, age, etc.). The image is published at `ghcr.io/ldruschk/vibecode-docker`.

## Key Files

| File | Purpose |
|---|---|---|
| `Dockerfile` | Image definition — Arch base, package install, opencode+crane binaries |
| `docker-compose.yml` | Service definition with env-var-based volume mounts |
| `README.md` | Usage examples, credential layout, repo initialization steps |
| `.github/workflows/main.yml` | CI/CD — builds and pushes to ghcr.io |
| `AI-CHANGELOG.md` | Record of AI-assisted changes |

## Build & Run

```bash
docker build -t ghcr.io/ldruschk/vibecode-docker:latest .
docker compose run --rm vibecode opencode
```

Portable usage (from any project directory, without copying `docker-compose.yml`):

```bash
# Add to .bashrc/.zshrc:
vibecode() {
  mkdir -p .credentials .credentials/.ssh
  [ -f .credentials/age-keys.txt ] || touch .credentials/age-keys.txt
  [ -f .credentials/github-token ] || touch .credentials/github-token
  [ -f .credentials/AGENTS.md ] || cat > .credentials/AGENTS.md <<'EOF'
# Credentials

- `.ssh/` — SSH deploy key for git push
- `age-keys.txt` — AGE private key for SOPS
- `github-token` — GitHub PAT for gh CLI
EOF
  GITCONFIG="$HOME/.gitconfig" \
  OPENCODE_CONFIG_DIR="$HOME/.config/opencode" \
  OPENCODE_DATA_DIR="$HOME/.local/share/opencode" \
  OPENCODE_STATE_DIR="$HOME/.local/state/opencode" \
  sudo docker compose -f /path/to/vibecode-docker/docker-compose.yml \
    --project-directory "$PWD" \
    run --rm vibecode opencode "$@"
}
```

## Credential Layout (`.credentials/`)

```
.credentials/
  .ssh/
    id_ed25519          # SSH deploy key
    id_ed25519.pub
    config              # SSH config for github.com
  age-keys.txt          # AGE private key for SOPS
  github-token          # Fine-grained PAT for gh automation
```

## Volume Mounts (docker-compose)

Path constants are parameterized via environment variables with defaults:

| Env Var | Default (Host) | Container | Purpose |
|---|---|---|---|
| — | `.` | `/workspace` | Project code |
| — | `.credentials/.ssh/` | `~/.ssh/` | SSH deploy key |
| — | `.credentials/age-keys.txt` | `~/.config/sops/age/keys.txt` | SOPS AGE key |
| `OPENCODE_CONFIG_DIR` | `/home/lucas/.config/opencode` | `~/.config/opencode` | OpenCode config, themes, keybinds |
| `OPENCODE_DATA_DIR` | `/home/lucas/.local/share/opencode` | `~/.local/share/opencode` | Auth, sessions |
| `OPENCODE_STATE_DIR` | `/home/lucas/.local/state/opencode` | `~/.local/state/opencode` | Logs, state |
| `GITCONFIG` | `/home/lucas/.gitconfig` | `~/.gitconfig:ro` | Git identity (persists across restarts) |

To persist git identity, add to your `docker-compose.yml`:
```yaml
volumes:
  - /home/user/.gitconfig:/home/vibecode/.gitconfig:ro
```

## Image Details

- **Base**: `archlinux:latest`
- **User**: `vibecode` (uid 1000, non-root, passwordless sudo via wheel group)
- **Workdir**: `/workspace`
- **opencode**: installed to `/usr/local/bin/opencode` via official install script
- **crane**: downloaded from `google/go-containerregistry` releases to `/usr/local/bin/crane`
- **hetzner-k3s**: downloaded from `vitobotta/hetzner-k3s` releases to `/usr/local/bin/hetzner-k3s`
- **Packages**: age, base-devel, git, curl, wget, openssh, gnupg, sudo, jq, go-yq, kubectl, helm, kustomize, github-cli, nodejs, npm, python, uv, ripgrep, fzf, tmux, vim, unzip, go, openssl, sops, direnv
- **Dockerfile patterns**:
  - Install script ignores `OPENCODE_INSTALL_DIR` — must `mv` binary from `/root/.opencode/bin` to `/usr/local/bin`
  - `sed -i 's/opencode -s/vibecode -s/g'` patches the compiled binary so the continue suggestion uses the `vibecode` wrapper command. Same-length replacement is safe on any binary.
  - File mounts into `~/.config/sops/age/` require pre-creating the directory tree owned by `vibecode` to prevent Docker from creating it as root (which blocks opencode from writing to `~/.config/opencode`)
