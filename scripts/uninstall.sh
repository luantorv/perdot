#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$SCRIPTS_DIR/core/state.sh"

cleanup_path() {
    log "Removing perdot from PATH configuration"
    
    local shell_rc=""
    case "$SHELL" in
        */bash) shell_rc="$HOME/.bashrc" ;;
        */zsh) shell_rc="$HOME/.zshrc" ;;
        */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
        *) return ;;
    esac
    
    if [[ ! -f "$shell_rc" ]]; then
        return
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "WOULD REMOVE perdot PATH config from $shell_rc"
        return
    fi
    
    # Remover las líneas agregadas por perdot
    sed -i '/# Added by perdot/,+1d' "$shell_rc"
    log "Removed PATH configuration from $shell_rc"
}

uninstall_self() {
    log "Uninstalling perdot"

    cleanup_path

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

uninstall_self