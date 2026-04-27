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
