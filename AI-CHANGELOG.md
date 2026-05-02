# AI-CHANGELOG

## 2026-04-27 — Initial setup

- Created `Dockerfile` with Arch Linux base, filtered package install, opencode CLI via install script, crane binary download, non-root `vibecode` user.
- Created `docker-compose.yml` (later moved to README example) mounting current directory to `/workspace`.
- Created `.gitignore` (later moved to README example) excluding `.credentials/`.
- Created `.github/workflows/main.yml` for CI/CD build and push to `ghcr.io`.
- Created `README.md` with usage examples, build instructions, and tool listing.
- Created `AGENTS.md` with project overview and instructions for AI agents.
- Created `AI-CHANGELOG.md` to track AI-assisted changes.

## 2026-04-27 — Add age, document `.credentials/` layout

- Added `age` package to Dockerfile.
- Updated docker-compose example: mount `.credentials/.ssh/` → `~/.ssh` and `.credentials/age-keys.txt` → `~/.config/sops/age/keys.txt`.
- Documented `.credentials/` directory structure in README.

## 2026-04-27 — Fix opencode install script

- Discovered `OPENCODE_INSTALL_DIR` env var is ignored by the install script. Reverted to `mv` from `/root/.opencode/bin` to `/usr/local/bin`.

## 2026-04-27 — Pre-create home directories, add persistent volumes

- Pre-created `~/.config/sops/age/`, `~/.local/share/opencode`, `~/.local/state/opencode`, `~/.ssh/` in Dockerfile to prevent Docker from creating them as root during bind mount, which was causing `EACCES` errors when opencode tried to write to `~/.config/opencode`.
- Added `~/.config/opencode` volume mount for persisting config, themes, keybinds.
- Added `~/.local/share/opencode` and `~/.local/state/opencode` mounts for auth, sessions, and logs.

## 2026-04-27 — Repository initialization docs

- Added repository initialization section to README: generate AGE key, SSH deploy key, create fine-grained PAT, add deploy key via `gh`.
- Documented required fine-grained PAT permissions: Administration (Write), Pull requests (Write), Actions (Read), Issues (Read), Contents (Read).
- Added `github-token` to `.credentials/` layout.

## 2026-04-27 — Portable docker-compose with dynamic env var paths

- Moved `docker-compose.yml` from README example into its own file in the repo root.
- Replaced hardcoded `/home/user/...` paths with `${VAR:-default}` env vars (`OPENCODE_CONFIG_DIR`, `OPENCODE_DATA_DIR`, `OPENCODE_STATE_DIR`, `GITCONFIG`).
- Added shell function snippet to README for portable usage — users add `vibecode()` to `.bashrc`/`.zshrc` that passes env vars from `$HOME` and uses `--project-directory "$PWD"`.
- Documented three usage options: shell function, `-f` + `--project-directory`, and symlink.

## 2026-04-27 — Add hetzner-k3s and sops binaries

- Added `hetzner-k3s-linux-amd64` download from GitHub releases to Dockerfile.
- Added `sops` package to Dockerfile.

## 2026-04-27 — Patch opencode binary continue suggestion

- Added `sed -i 's/opencode -s/vibecode -s/g'` to Dockerfile to replace the continue command in opencode's output so it displays `vibecode -s <id>` instead of `opencode -s <id>`. Same-length byte replacement is safe on compiled binaries.

## 2026-04-27 — Add GITCONFIG volume mount, document sops

- Added `${GITCONFIG:-/home/lucas/.gitconfig}` volume mount to docker-compose.yml.
- Added `GITCONFIG="$HOME/.gitconfig"` to the shell function in README.
- Added `.gitconfig` mount docs and `sops` to package list in AGENTS.md.

## 2026-04-29 — Canonical function file + install script

- Created `vibecode-function.sh` as the single source of truth for the `vibecode()` shell function.
- Created `install-vibecode-function.sh` which reads the canonical definition and inserts/updates it in `~/.zshrc` between marker comments.
- Replaced duplicated inline function bodies in README and AGENTS.md with references to the install script.
