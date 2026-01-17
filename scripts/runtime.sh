#!/usr/bin/env bash
set -euo pipefail

# Paths base
DOTFILES_ROOT="${DOTFILES_ROOT:?DOTFILES_ROOT not set}"

FILES_DIR="$DOTFILES_ROOT/files"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"
STATE_DIR="$DOTFILES_ROOT/state"
BACKUP_DIR="$STATE_DIR/backups"
RUNTIME_DIR="$STATE_DIR/runtime"
CACHE_DIR="$STATE_DIR/cache"

TOUCHED_FILE="$RUNTIME_DIR/last_run.touched"

# Garantizar estructura mínima
mkdir -p \
    "$STATE_DIR" \
    "$BACKUP_DIR" \
    "$RUNTIME_DIR" \
    "$CACHE_DIR"

touch "$TOUCHED_FILE"

ensure_state() {
    mkdir -p \
        "$STATE_DIR/backups" \
        "$STATE_DIR/locks" \
        "$STATE_DIR/logs"

    local touched="$STATE_DIR/last_run.touched"

    if [[ ! -f "$touched" ]]; then
        touch "$touched"
        log "Created state file: last_run.touched"
    fi
}