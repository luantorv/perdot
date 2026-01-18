#!/usr/bin/env bash

log() {
    [[ "${VERBOSE:-0}" == "1" ]] && echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

version_ge() {
    # version_ge INSTALLED REQUIRED
    [[ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

ok()   { echo "[OK]   $*"; }
warn() { echo "[WARN] $*"; }
err()  { echo "[ERR]  $*"; [[ "${STRICT:-0}" == "1" ]] && exit 1; }

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

backup_file() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$file"

    ensure_backup_dir
    mkdir -p "$(dirname "$backup_path")"
    cp -a "$file" "$backup_path"
}

rollback() {
    warn "Error detected, rolling back changes"

    if [[ ! -f "$TOUCHED_FILE" ]]; then
        warn "No rollback information available"
        return
    fi

    tac "$TOUCHED_FILE" | while read -r dest; do
        backup="$BACKUP_DIR/$dest"

        if [[ -e "$backup" ]]; then
            rm -f "$dest"
            mkdir -p "$(dirname "$dest")"
            cp -a "$backup" "$dest"
            log "Restored $dest"
        else
            rm -f "$dest"
            log "Removed $dest"
        fi
    done
}

git_has_changes() {
    git -C "$DOTFILES_ROOT" diff --quiet HEAD@{1} HEAD -- || return 0
    return 1
}