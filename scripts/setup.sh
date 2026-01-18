#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"

ensure_systemd_user() {
    if ! systemctl --user status >/dev/null 2>&1; then
        err "systemd user session not available"
        exit 1
    fi
}

setup_units() {
    local units_dir="$FILES_DIR/systemd/user"
    local target_dir="$HOME/.config/systemd/user"

    [[ -d "$units_dir" ]] || return 0

    mkdir -p "$target_dir"

    find "$units_dir" -type f -name "*.service" | while read -r unit; do
        local name
        name="$(basename "$unit")"
        local dest="$target_dir/$name"

        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD LINK: $dest -> $unit"
            continue
        fi

        ln -sf "$unit" "$dest"
        log "Linked unit $name"
    done
}

enable_units() {
    local target_dir="$HOME/.config/systemd/user"

    find "$target_dir" -type l -name "*.service" | while read -r unit; do
        local name
        name="$(basename "$unit")"

        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD ENABLE: $name"
            continue
        fi

        systemctl --user enable --now "$name"
        log "Enabled $name"
    done
}

setup() {
    log "Running perdot setup"

    ensure_state
    ensure_systemd_user

    setup_units
    enable_units

    log "Setup complete"
}

setup "@"