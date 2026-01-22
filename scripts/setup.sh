#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$SCRIPTS_DIR/core/services.sh"
source "$SCRIPTS_DIR/core/state.sh"

setup() {
    log "Running perdot setup"

    ensure_state
    ensure_systemd_user

    setup_units
    enable_units

    log "Setup complete"
}

setup