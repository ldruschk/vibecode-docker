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
  sudo docker compose -f __COMPOSE_FILE__ \
    --project-directory "$PWD" \
    run --rm vibecode opencode "$@"
}
