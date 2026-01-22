#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/runtime.sh"

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

ensure_backup_dir() {
    [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"
}