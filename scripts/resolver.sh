#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"
source "$(dirname "$0")/backup.sh"

case "$ACTION" in
    i|install)   SCRIPT="$SCRIPTS_DIR/install.sh" ;;
    u|update)    SCRIPT="$SCRIPTS_DIR/update.sh" ;;
    S|setup)     SCRIPT="$SCRIPTS_DIR/setup.sh" ;;
    s|status)    SCRIPT="$SCRIPTS_DIR/status.sh" ;;
    d|doctor)    SCRIPT="$SCRIPTS_DIR/doctor.sh" ;;
    r|uninstall) SCRIPT="$SCRIPTS_DIR/uninstall.sh" ;;
    *)
        err "Unknown action: $ACTION"
        exit 1
        ;;
esac

source "$SCRIPT"