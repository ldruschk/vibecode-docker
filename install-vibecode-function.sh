#!/usr/bin/env bash
set -euo pipefail

ZSCRC="${ZDOTDIR:-$HOME}/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
FUNC_FILE="$SCRIPT_DIR/vibecode-function.sh"
MARKER_START="# --- vibecode() start ---"
MARKER_END="# --- vibecode() end ---"

[ -f "$FUNC_FILE" ] || { echo "Error: $FUNC_FILE not found" >&2; exit 1; }

FUNC_BODY=$(sed "s|__COMPOSE_FILE__|$COMPOSE_FILE|g" "$FUNC_FILE")

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

{
  printf '%s\n' "$MARKER_START"
  printf '%s\n' "$FUNC_BODY"
  printf '%s\n' "$MARKER_END"
} > "$TMPFILE"

if grep -q "$MARKER_START" "$ZSCRC" 2>/dev/null; then
  sed -i "
    /^$MARKER_START$/,/^$MARKER_END$/{
      /^$MARKER_START$/{
        r $TMPFILE
      }
      d
    }
  " "$ZSCRC"
  echo "Updated vibecode() in $ZSCRC"
else
  cat "$TMPFILE" >> "$ZSCRC"
  echo "Appended vibecode() to $ZSCRC"
fi
