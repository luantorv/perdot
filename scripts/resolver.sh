#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

FILES_DIR="$DOTFILES_ROOT/files"
MAPPINGS_FILE="$DOTFILES_ROOT/mappings/default.map"
STATE_DIR="$DOTFILES_ROOT/state"


PLAN_FILE="$(mktemp)"

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

TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"

ensure_backup_dir() {
    [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"
}

backup_file() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$file"

    ensure_backup_dir
    mkdir -p "$(dirname "$backup_path")"
    cp -a "$file" "$backup_path"
}

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

            ln -sf "$file" "$dest"
            log "Linked $dest -> $file"
        done
    done < "$PLAN_FILE"
}

log "dotfile $ACTION"

build_plan

if [[ "$DRY_RUN" == "1" ]]; then
    show_plan
else
    apply_plan
fi

