#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh" 

install_self() {
    log "Installing perdot command"

    if [[ "$DRY_RUN" == "1" ]]; then
        echo "WOULD LINK: $GLOBAL_BIN -> $SOURCE_BIN"
        return
    fi

    mkdir -p "$LOCAL_BIN"

    if [[ -e "$GLOBAL_BIN" && "$FORCE" != "1" ]]; then
        warn "$GLOBAL_BIN already exists (use --force to replace)"
        return
    fi

    ln -sf "$SOURCE_BIN" "$GLOBAL_BIN"
    log "perdot available at $GLOBAL_BIN"
}

log "Initializing perdot state"
mkdir -p "$STATE_DIR"/{backups,cache}

install_self "@"