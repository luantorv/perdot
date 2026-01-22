#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/runtime.sh"

build_plan() {
    local all_packages=("${PACKAGES[@]}" "${AUR_PACKAGES[@]}")
    
    for pkg in "${all_packages[@]}"; do
        local target
        target="$(get_target_path "$pkg")"
        [[ -n "$target" ]] || { warn "No mapping for $pkg"; continue; }

        # SIEMPRE procesar base/ si existe
        if [[ -d "$FILES_DIR/$pkg/base" ]]; then
            echo "$pkg|$FILES_DIR/$pkg/base|$target" >> "$PLAN_FILE"
            log "Resolving $pkg (base)"
        fi

        # Opcionalmente añadir versiones específicas
        local version
        version="$(get_installed_version "$pkg")"
        if [[ -n "$version" ]]; then
            log "Detected $pkg $version"
            resolve_package_versions "$pkg" "$version" | while read -r v; do
                [[ "$v" != "base" ]] && echo "$pkg|$FILES_DIR/$pkg/$v|$target" >> "$PLAN_FILE"
            done
        fi
    done
}

show_plan() {
    echo "PLAN:"
    column -t -s'|' "$PLAN_FILE"
}