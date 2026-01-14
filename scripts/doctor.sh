#!/usr/bin/env bash
set -euo pipefail

doctor() {
    echo "Running perdot doctor"
    echo

    # 1. Repo
    [[ -d "$DOTFILES_ROOT/.git" ]] \
        && ok "Git repository detected" \
        || err "Not a git repository"

    git -C "$DOTFILES_ROOT" status --porcelain >/dev/null 2>&1 \
        && ok "Git repository is accessible" \
        || err "Cannot access git repository"

    # 2. Layout
    [[ -d "$FILES_DIR" ]] \
        && ok "files/ directory exists" \
        || err "files/ directory missing"

    [[ -f "$MAPPINGS_FILE" ]] \
        && ok "Mappings file present" \
        || err "Mappings file missing"

    [[ -d "$STATE_DIR" ]] \
        && ok "state/ directory exists" \
        || warn "state/ directory missing (will be created on demand)"

    # 3. Tools
    for cmd in pacman git awk ln; do
        command -v "$cmd" >/dev/null \
            && ok "Command '$cmd' available" \
            || err "Missing command: $cmd"
    done

    # 4. Optional tools
    if [[ "$PACKAGES" == "1" ]]; then
        command -v sudo >/dev/null \
            && ok "sudo available for package install" \
            || err "sudo required for --packages"
    fi

    if [[ "$AUR" == "1" ]]; then
        command -v yay >/dev/null \
            && ok "yay available for AUR packages" \
            || warn "AUR requested but yay not found"
    fi

    # 5. Package presence (no instalación)
    for pkg in "${PACKAGES[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            ok "Package installed: $pkg"
        else
            warn "Package not installed: $pkg"
        fi
    done

    if [[ -L "$GLOBAL_BIN" ]]; then
        ok "perdot is installed in ~/.local/bin"
    else
        warn "perdot not installed globally (run: perdot install)"
    fi

    echo "$PATH" | grep -q "$LOCAL_BIN" \
        && ok "~/.local/bin is in PATH" \
        || warn "~/.local/bin not in PATH"

    echo
    ok "Doctor finished"
}
