#!/usr/bin/env bash
set -euo pipefail

# Paths base
DOTFILES_ROOT="${DOTFILES_ROOT:?DOTFILES_ROOT not set}"

FILES_DIR="$DOTFILES_ROOT/files"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"
STATE_DIR="$DOTFILES_ROOT/state"
BACKUP_DIR="$STATE_DIR/backups"
RUNTIME_DIR="$STATE_DIR/runtime"
CACHE_DIR="$STATE_DIR/cache"

TOUCHED_FILE="$RUNTIME_DIR/last_run.touched"

FILES_DIR="$DOTFILES_ROOT/files"
MAPPINGS_FILE="$DOTFILES_ROOT/mappings/default.map"
PLAN_FILE="$(mktemp)"

LOCAL_BIN="$HOME/.local/bin"
GLOBAL_BIN="$LOCAL_BIN/perdot"
SOURCE_BIN="$DOTFILES_ROOT/bin/perdot"

PACKAGES=(
    hyprland
    eww
    rofi
    mako
    swww
    hyprlock
    wlogout
    grim
    slurp
    swappy
    pavucontrol
    wl-clipboard
    cliphist
    hypridle
)

AUR_PACKAGES=(
    # vacío por ahora
)

SERVICES_MAP=(
    "mako:mako.service"
    "hypridle:hypridle.service"
)

CHECK_PACCKAGE=0

# Garantizar estructura mínima
mkdir -p \
    "$STATE_DIR" \
    "$BACKUP_DIR" \
    "$RUNTIME_DIR" \
    "$CACHE_DIR"

touch "$TOUCHED_FILE"
