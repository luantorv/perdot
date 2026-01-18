#!/usr/bin/env bash
set -euo pipefail

# Paths base
DOTFILES_ROOT="${DOTFILES_ROOT:?DOTFILES_ROOT not set}"

FILES_DIR="$DOTFILES_ROOT/files"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"
STATE_DIR="$DOTFILES_ROOT/state"
BACKUP_DIR="$STATE_DIR/backups"
RUNTIME_DIR="$STATE_DIR/runtime"
CACHE_DIR="$STATE_DIR/cache"

TOUCHED_FILE="$RUNTIME_DIR/last_run.touched"

FILES_DIR="$DOTFILES_ROOT/files"
MAPPINGS_FILE="$DOTFILES_ROOT/mappings/default.map"
PLAN_FILE="$(mktemp)"

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

CHECK_PACCKAGE=0

# Garantizar estructura mínima
mkdir -p \
    "$STATE_DIR" \
    "$BACKUP_DIR" \
    "$RUNTIME_DIR" \
    "$CACHE_DIR"

touch "$TOUCHED_FILE"

ensure_state() {
    mkdir -p \
        "$STATE_DIR/backups" \
        "$STATE_DIR/locks" \
        "$STATE_DIR/logs"

    local touched="$STATE_DIR/last_run.touched"

    if [[ ! -f "$touched" ]]; then
        touch "$touched"
        log "Created state file: last_run.touched"
    fi
}

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
