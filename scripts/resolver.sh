#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$(dirname "$0")/backup.sh"

case "$ACTION" in
    i|install)   source "$SCRIPTS_DIR/install.sh" ;;
    u|update)    source "$SCRIPTS_DIR/update.sh" ;;
    S|setup)     source "$SCRIPTS_DIR/setup.sh" ;;
    s|status)    source "$SCRIPTS_DIR/status.sh" ;;
    d|doctor)    source "$SCRIPTS_DIR/doctor.sh" ;;
    r|uninstall) source "$SCRIPTS_DIR/uninstall.sh" ;;
    *)
        err "Unknown action: $ACTION"
        exit 1
        ;;
esac