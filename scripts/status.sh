#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"

status_packages() {
    echo "[PACKAGES]"

    for pkg in "${PACKAGES[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            ver="$(pacman -Q "$pkg" | awk '{print $2}')"
            ok "$pkg $ver"
        else
            warn "$pkg not installed"
        fi
    done
}

status_configs() {
    echo "[CONFIGS]"

    build_plan

    while IFS='|' read -r pkg src target; do
        find "$src" -type f | while read -r file; do
            rel="${file#$src/}"
            dest="$target/$rel"

            if [[ ! -e "$dest" ]]; then
                warn "$dest (missing)"
                continue
            fi

            if [[ -L "$dest" ]]; then
                link="$(readlink "$dest")"
                if [[ "$link" == "$file" ]]; then
                    ok "$dest -> $link"
                else
                    err "$dest (points to $link)"
                fi
            else
                warn "$dest (not a symlink)"
            fi
        done
    done < "$PLAN_FILE"
}

status_backups() {
    echo "[BACKUPS]"

    if [[ ! -d "$STATE_DIR/backups" ]]; then
        warn "No backups found"
        return
    fi

    count="$(ls -1 "$STATE_DIR/backups" | wc -l)"
    ok "$count backup snapshots available"
}

status() {
    echo "perdot status"
    echo

    echo "[CORE]"

    if [[ -L "$GLOBAL_BIN" ]]; then
        ok "perdot installed"
    else
        warn "perdot not installed"
    fi

    echo "$PATH" | grep -q "$LOCAL_BIN" \
        && ok "~/.local/bin in PATH" \
        || warn "~/.local/bin not in PATH"

    echo
    status_packages
    echo
    status_configs
    echo
    status_backups
}
