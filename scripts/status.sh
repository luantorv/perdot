#!/usr/bin/env bash
set -euo pipefail

source "$SCRIPTS_DIR/runtime.sh"
source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/core/plan.sh"

check_repo() {
    echo "Repository"

    if [[ -d "$DOTFILES_ROOT/.git" ]]; then
        ok "Git repository detected"
    else
        err "Not a git repository"
    fi

    echo
}

check_paths() {
    echo "Paths"

    [[ -d "$FILES_DIR" ]] \
        && ok "files/ directory exists" \
        || err "files/ directory missing"

    [[ -f "$MAPPINGS_FILE" ]] \
        && ok "Mappings file present" \
        || err "Mappings file missing"

    echo
}

check_state() {
    echo "State"

    if [[ -d "$STATE_DIR" ]]; then
        ok "state/ directory exists"
    else
        warn "state/ directory missing"
        return
    fi

    [[ -d "$STATE_DIR/backups" ]] \
        && ok "backups/ directory present" \
        || warn "backups/ directory missing"

    [[ -f "$STATE_DIR/last_run.touched" ]] \
        && ok "last_run.touched present" \
        || warn "last_run.touched missing"

    echo
}

check_symlinks() {
    echo "Dotfiles"

    local broken=0

    while IFS='|' read -r pkg src target; do
        find "$src" -type f | while read -r file; do
            local rel="${file#$src/}"
            local dest="$target/$rel"

            if [[ -L "$dest" ]]; then
                ok "Linked: $dest"
            elif [[ -e "$dest" ]]; then
                warn "Not a symlink: $dest"
                broken=1
            else
                warn "Missing: $dest"
                broken=1
            fi
        done
    done < <(build_plan)

    [[ "$broken" == "0" ]] || warn "Some dotfiles are missing or incorrect"
    echo
}

check_services() {
    echo "User services"

    local units_dir="$HOME/.config/systemd/user"

    [[ -d "$units_dir" ]] || {
        warn "No user systemd units directory"
        echo
        return
    }

    find "$units_dir" -type l -name "*.service" | while read -r unit; do
        local name
        name="$(basename "$unit")"

        if systemctl --user is-active --quiet "$name"; then
            ok "Active: $name"
        else
            warn "Inactive: $name"
        fi
    done

    echo
}

status() {
    echo "perdot status"
    echo

    check_repo
    check_paths
    check_state
    check_symlinks
    check_services

    echo
    ok "Status check completed"
}

status