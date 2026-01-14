#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$DOTFILES_ROOT/state"
BACKUP_DIR="$STATE_DIR/backups"
CACHE_DIR="$STATE_DIR/cache"

mkdir -p "$STATE_DIR" "$BACKUP_DIR" "$CACHE_DIR"
