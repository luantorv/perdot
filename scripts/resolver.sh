#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

FILES_DIR="$DOTFILES_ROOT/files"
MAPPINGS_FILE="$DOTFILES_ROOT/mappings/default.map"
STATE_DIR="$DOTFILES_ROOT/state"
PLAN_FILE="$(mktemp)"
TOUCHED_FILE="$STATE_DIR/last_run.touched" > "$TOUCHED_FILE"

LOCAL_BIN="$HOME/.local/bin"
GLOBAL_BIN="$LOCAL_BIN/perdot"
SOURCE_BIN="$DOTFILES_ROOT/bin/perdot"

PACKAGES=(
    hyprland
    eww
    rofi
    mako
    swww
    hyprlock
    wlogout
    grim
    slurp
    swappy
    pavucontrol
    wl-clipboard
    cliphist
    hypridle
)

AUR_PACKAGES=(
    # vacío por ahora
)

SERVICES_MAP=(
    "mako:mako.service"
    "hypridle:hypridle.service"
)

source "$(dirname "$0")/doctor.sh"
source "$(dirname "$0")/update.sh"
source "$(dirname "$0")/install.sh"
source "$(dirname "$0")/uninstall.sh"

get_installed_version() {
    pacman -Q "$1" 2>/dev/null | awk '{print $2}' || true
}

get_target_path() {
    awk -v p="$1" '$1 == p {print $2}' "$MAPPINGS_FILE"
}

resolve_package_versions() {
    local pkg="$1"
    local installed_version="$2"
    local dir="$FILES_DIR/$pkg"

    [[ -d "$dir" ]] || return 0

    local result=()

    [[ -d "$dir/base" ]] && result+=("base")

    for vdir in "$dir"/'>='*; do
        [[ -d "$vdir" ]] || continue
        local req="${vdir##*/>=}"
        version_ge "$installed_version" "$req" && result+=(">=${req}")
    done

    printf '%s\n' "${result[@]}" | sort -V
}

build_plan() {
    for pkg in "${PACKAGES[@]}"; do
        local version
        version="$(get_installed_version "$pkg")"

        [[ -n "$version" ]] || continue

        log "Resolving $pkg ($version)"

        local target
        target="$(get_target_path "$pkg")"
        [[ -n "$target" ]] || { warn "No mapping for $pkg"; continue; }

        resolve_package_versions "$pkg" "$version" | while read -r v; do
            echo "$pkg|$FILES_DIR/$pkg/$v|$target" >> "$PLAN_FILE"
        done
    done
}

show_plan() {
    echo "PLAN:"
    column -t -s'|' "$PLAN_FILE"
}

source "$(dirname "$0")/backup.sh"
source "$(dirname "$0")/status.sh"

apply_plan() {
    while IFS='|' read -r pkg src target; do
        find "$src" -type f | while read -r file; do
            rel="${file#$src/}"
            dest="$target/$rel"

            if [[ "$DRY_RUN" == "1" ]]; then
                echo "WOULD LINK: $dest -> $file"
                continue
            fi

            mkdir -p "$(dirname "$dest")"

            if [[ -e "$dest" ]]; then
                if [[ "$FORCE" != "1" ]]; then
                    warn "Skipping existing file: $dest"
                    continue
                fi

                if [[ "$DRY_RUN" != "1" ]]; then
                    backup_file "$dest"
                    log "Backed up $dest"
                fi
            fi

            echo "$dest" >> "$TOUCHED_FILE"
            ln -sf "$file" "$dest"
            log "Linked $dest -> $file"
        done
    done < "$PLAN_FILE"
}

log "dotfile $ACTION"

if [[ "$ACTION" == "status" ]]; then
    status
    exit 0
fi

if [[ "$ACTION" == "uninstall" ]]; then
    uninstall_self
    exit 0
fi

if [[ "$ACTION" == "doctor" ]]; then
    doctor
    exit 0
fi

if [[ "$ACTION" == "install" ]]; then
    install_self
fi

if [[ "$ACTION" == "update" || "$ACTION" == "install" ]]; then
    sync_packages
fi

if [[ "$ACTION" == "update" ]]; then
    do_update
fi

build_plan

if [[ "$DRY_RUN" == "1" ]]; then
    show_plan
else
    trap rollback ERR
    apply_plan
    restart_services
fi

