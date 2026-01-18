#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$SCRIPTS_DIR/core/state.sh"

uninstall_self() {
    log "Uninstalling perdot"

    # 1. Remove symlink
    if [[ -L "$GLOBAL_BIN" ]]; then
        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD REMOVE: $GLOBAL_BIN"
        else
            rm "$GLOBAL_BIN"
            log "Removed $GLOBAL_BIN"
        fi
    else
        warn "No perdot symlink found in ~/.local/bin"
    fi

    # 2. Purge state
    if [[ "$PURGE_STATE" == "1" && -d "$STATE_DIR" ]]; then
        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD REMOVE: $STATE_DIR"
        else
            rm -rf "$STATE_DIR"
            log "Removed state directory"
        fi
    fi

    # 3. Purge backups only
    if [[ "$PURGE_BACKUPS" == "1" && -d "$STATE_DIR/backups" ]]; then
        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD REMOVE: $STATE_DIR/backups"
        else
            rm -rf "$STATE_DIR/backups"
            log "Removed backups"
        fi
    fi
}

uninstall_self "@"