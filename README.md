# vibecode-docker

Arch Linux based Docker image for the [Opencode CLI](https://github.com/anomalyco/opencode) with DevOps tooling.

> This project was vibecoded entirely with [opencode](https://opencode.ai).

## Usage

### Portable usage (recommended)

Clone this repo once, then add a shell function to your `~/.bashrc` or `~/.zshrc`:

```bash
export VIBECODE_DOCKER_DIR="$HOME/Documents/prog/vibecode-docker"

vibecode() {
  OPENCODE_CONFIG_DIR="$HOME/.config/opencode" \
  OPENCODE_DATA_DIR="$HOME/.local/share/opencode" \
  OPENCODE_STATE_DIR="$HOME/.local/state/opencode" \
  sudo docker compose -f "$VIBECODE_DOCKER_DIR/docker-compose.yml" \
    --project-directory "$PWD" \
    run --rm vibecode opencode "$@"
}
```

Now from any project directory, just run:

```bash
vibecode
```

The `--project-directory .` ensures relative volume mounts (`.`, `.credentials/`) resolve against your current project, while the compose file lives in one central place.

### docker-compose.yml (for reference)

The canonical compose file lives in this repo at [`docker-compose.yml`](docker-compose.yml). You can also use it directly without the shell function:

```bash
sudo docker compose -f /path/to/vibecode-docker/docker-compose.yml --project-directory . run --rm vibecode opencode
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
   - Administration: **Write** (manage deploy keys)
   - Pull requests: **Write** (manage PRs)
   - Actions: **Read** (check CI runs)
   - Issues: **Read** (view issues)
   - Contents: **Read** (clone, inspect files)
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

Start an interactive opencode session from any project directory:

```bash
# If you set up the shell function (recommended):
vibecode

# Or directly:
sudo docker compose -f /path/to/vibecode-docker/docker-compose.yml --project-directory . run --rm vibecode opencode
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
