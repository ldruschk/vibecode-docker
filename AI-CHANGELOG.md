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
