#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$SCRIPTS_DIR/core/apply.sh"
source "$SCRIPTS_DIR/core/state.sh"

setup_path() {
    log "Configuring PATH for perdot"
    
    # Detectar el shell del usuario
    local shell_rc=""
    case "$SHELL" in
        */bash)
            shell_rc="$HOME/.bashrc"
            ;;
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
        *)
            warn "Unknown shell: $SHELL, skipping PATH setup"
            return
            ;;
    esac
    
    # Verificar si ya está en el archivo
    if grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$shell_rc" 2>/dev/null; then
        log "PATH already configured in $shell_rc"
        return
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "WOULD ADD to $shell_rc: export PATH=\"\$HOME/.local/bin:\$PATH\""
        return
    fi
    
    # Agregar al archivo
    echo "" >> "$shell_rc"
    echo "# Added by perdot" >> "$shell_rc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$shell_rc"
    
    log "Added $LOCAL_BIN to PATH in $shell_rc"
    warn "Restart your shell or run: source $shell_rc"
}

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

install_self
setup_path