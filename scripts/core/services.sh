#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/runtime.sh"

sync_packages() {
    [[ "$PACKAGES" == "1" ]] || return 0

    log "Syncing system packages"

    if [[ "$DRY_RUN" == "1" ]]; then
        echo "WOULD RUN: sudo pacman -Syu --needed ${PACKAGES[*]}"
        [[ "$AUR" == "1" ]] && echo "WOULD RUN: yay -Syu --needed ${AUR_PACKAGES[*]}"
        return
    fi

    sudo pacman -Syu --needed "${SYSTEM_PACKAGES[@]}"

    if [[ "$AUR" == "1" ]] && command -v yay >/dev/null; then
        yay -Syu --needed "${AUR_PACKAGES[@]}"
    fi
}

restart_services() {
    [[ "$SERVICES" == "1" ]] || return 0

    log "Restarting services"

    for entry in "${SERVICES_MAP[@]}"; do
        IFS=':' read -r pkg svc <<< "$entry"

        if ! systemctl --user list-unit-files | grep -q "$svc"; then
            continue
        fi

        if [[ "$DRY_RUN" == "1" ]]; then
            echo "WOULD RUN: systemctl --user restart $svc"
        else
            systemctl --user restart "$svc"
            log "Restarted $svc"
        fi
    done
}

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