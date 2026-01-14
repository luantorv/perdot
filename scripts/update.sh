#!/usr/bin/env bash
set -euo pipefail

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

git_has_changes() {
    git -C "$DOTFILES_ROOT" diff --quiet HEAD@{1} HEAD -- || return 0
    return 1
}

do_update() {
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