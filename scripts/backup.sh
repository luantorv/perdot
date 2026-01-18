#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/runtime.sh"

TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"