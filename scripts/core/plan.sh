#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/runtime.sh"

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