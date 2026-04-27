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
      - ./.credentials/.ssh:/home/vibecode/.ssh
      - ./.credentials/age-keys.txt:/home/vibecode/.config/sops/age/keys.txt
      - /home/user/.local/share/opencode:/home/vibecode/.local/share/opencode
      - /home/user/.local/state/opencode:/home/vibecode/.local/state/opencode
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

Place credentials in `.credentials/` at the project root. This folder is excluded from Git.

```
.credentials/
  .ssh/
    id_ed25519          # SSH private key (deploy key)
    id_ed25519.pub      # SSH public key
    config              # SSH config (auto-uses key for github.com)
    known_hosts         # Generated on first SSH connection
  age-keys.txt          # AGE private key (for SOPS decryption)
  github-token          # Fine-grained PAT (repo-scoped, for gh automation)
```

Mount points:
- `.credentials/.ssh/` → `~/.ssh/` — SSH keys for git push
- `.credentials/age-keys.txt` → `~/.config/sops/age/keys.txt` — AGE key for SOPS
- `.credentials/github-token` → available at `/workspace/.credentials/github-token`

## Repository Initialization

Run these steps inside the container to set up a new repo with SSH deploy key, AGE key, and a GitHub token for `gh`.

### 1. Generate AGE key

```bash
age-keygen -o .credentials/age-keys.txt
```

### 2. Generate SSH deploy key

```bash
ssh-keygen -t ed25519 -f .credentials/.ssh/id_ed25519 -N "" -C "deploy-key@<owner>/<repo>"
```

### 3. Create a GitHub fine-grained PAT

1. Go to **GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. **Token name**: `deploy-key-manager`
3. **Repository access**: Only select repositories → choose your repo
4. **Permissions** → Repository permissions:
   - Administration: **Write** (needed to manage deploy keys)
5. Click **Generate token**
6. Copy the token into `.credentials/github-token`:

```bash
echo "github_pat_..." > .credentials/github-token
```

### 4. Authenticate `gh` and add the deploy key

```bash
gh auth login --with-token < .credentials/github-token
gh repo deploy-key add .credentials/.ssh/id_ed25519.pub \
  --repo <owner>/<repo> --allow-write
```

The deploy key is now active: the SSH private key at `.credentials/.ssh/id_ed25519` can push to your repo.

### 5. Verify

```bash
ssh -T git@github.com
age -d .credentials/age-keys.txt </dev/null 2>&1 | head -1
```

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
