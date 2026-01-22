#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$SCRIPTS_DIR/core/plan.sh"
source "$SCRIPTS_DIR/core/services.sh" 

update() {
    log "Updating dotfiles repository"

    if [[ ! -d "$DOTFILES_ROOT/.git" ]]; then
        warn "Not a git repository, skipping update"
        return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        echo "WOULD RUN: git pull --ff-only"
        return
    fi

    git -C "$DOTFILES_ROOT" pull --ff-only

    if git_has_changes; then
        log "Repository updated, re-applying configs"
    else
        log "No changes detected"
        exit 0
    fi
}

update