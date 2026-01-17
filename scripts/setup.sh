#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SETUP_STATE_DIR="$STATE_DIR/setup"
ENABLED_LOG="$SETUP_STATE_DIR/enabled_services.log"
LAST_SETUP_FILE="$SETUP_STATE_DIR/last_setup"

CORE_SERVICES=(
    cliphist.service
    swww-init.service
    mako.service
    hypridle.service
    eww.service
)

validate_environment() {
    log "Validating environment"

    [[ -n "${XDG_RUNTIME_DIR:-}" ]] \
        || err "XDG_RUNTIME_DIR not set (no user session?)"

    command -v systemctl >/dev/null \
        || err "systemctl not available"

    systemctl --user status >/dev/null 2>&1 \
        || err "systemd user session not available"

    ok "Environment looks sane"
}

ensure_state_dirs() {
    [[ -d "$SETUP_STATE_DIR" ]] || {
        if [[ "$DRY_RUN" == "1" ]]; then
            log "Would create state dir: $SETUP_STATE_DIR"
        else
            mkdir -p "$SETUP_STATE_DIR"
            ok "Created setup state directory"
        fi
    }
}

reload_systemd_user() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log "Would reload systemd user daemon"
    else
        systemctl --user daemon-reexec
        ok "Reloaded systemd user daemon"
    fi
}

service_exists() {
    local svc="$1"
    [[ -f "$SYSTEMD_USER_DIR/$svc" ]] \
        || systemctl --user cat "$svc" >/dev/null 2>&1
}

enable_service() {
    local svc="$1"

    if systemctl --user is-enabled "$svc" >/dev/null 2>&1; then
        ok "Service already enabled: $svc"
        [[ "$FORCE" == "1" ]] || return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log "Would enable service: $svc"
    else
        systemctl --user enable "$svc"
        echo "$svc" >> "$ENABLED_LOG"
        ok "Enabled service: $svc"
    fi
}

start_service() {
    local svc="$1"

    if systemctl --user is-active "$svc" >/dev/null 2>&1; then
        ok "Service already running: $svc"
        [[ "$FORCE" == "1" ]] || return
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        log "Would start service: $svc"
    else
        systemctl --user start "$svc"
        ok "Started service: $svc"
    fi
}

setup_services() {
    log "Setting up user services"

    for svc in "${CORE_SERVICES[@]}"; do
        if service_exists "$svc"; then
            enable_service "$svc"
            start_service "$svc"
        else
            warn "Service not found, skipping: $svc"
        fi
    done
}

record_setup() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log "Would record setup timestamp"
    else
        date +"%Y-%m-%d %H:%M:%S" > "$LAST_SETUP_FILE"
        ok "Setup completed"
    fi
}

setup() {
    log "Running perdot setup"

    validate_environment
    ensure_state_dirs
    reload_systemd_user
    setup_services
    record_setup
}
