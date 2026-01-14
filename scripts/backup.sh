#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"

ensure_backup_dir() {
    [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"
}

backup_file() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$file"

    ensure_backup_dir
    mkdir -p "$(dirname "$backup_path")"
    cp -a "$file" "$backup_path"
}

rollback() {
    warn "Error detected, rolling back changes"

    if [[ ! -f "$TOUCHED_FILE" ]]; then
        warn "No rollback information available"
        return
    fi

    tac "$TOUCHED_FILE" | while read -r dest; do
        backup="$BACKUP_DIR/$dest"

        if [[ -e "$backup" ]]; then
            rm -f "$dest"
            mkdir -p "$(dirname "$dest")"
            cp -a "$backup" "$dest"
            log "Restored $dest"
        else
            rm -f "$dest"
            log "Removed $dest"
        fi
    done
}