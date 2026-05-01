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
| `install-vibecode-function.sh` | Installs/updates the `vibecode()` shell function in `~/.zshrc` |
| `vibecode-function.sh` | Canonical definition of the `vibecode()` shell function |

## Build & Run

```bash
docker build -t ghcr.io/ldruschk/vibecode-docker:latest .
docker compose run --rm vibecode opencode
```

## Installing the Shell Function

The canonical function definition lives in [`vibecode-function.sh`](vibecode-function.sh). Run the install script to add or update it in `~/.zshrc`:

```bash
# Clone once, then:
/path/to/vibecode-docker/install-vibecode-function.sh
# Reload your shell:
exec zsh
```

The function auto-resolves the compose file path from the install script's own directory, so there's no need to edit any paths.

The function supports a `--name <value>` flag that is forwarded as `VIBECODE_NAME` into the container. Any other arguments are passed through to `opencode` unchanged.

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
| `VIBECODE_NAME` | — | — | Session name passed via `--name` flag to `vibecode()` |

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
