#!/usr/bin/env bash
set -euo pipefail

# Paths base
DOTFILES_ROOT="$HOME/perdot"

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
    # Core Hyprland
    "hyprland"
    "eww"
    "rofi"
    "mako"
    "kitty"
    
    # Utilidades Wayland
    "grim"
    "slurp"
    "swappy"
    "wl-clipboard"
    
    # Sistema
    "brightnessctl"
    "networkmanager"
    "network-manager-applet"
    "polkit-gnome"
    "blueman"
    "udisks2"
    
    # Audio
    "pipewire"
    "wireplumber"
    "pipewire-pulse"
    "pipewire-alsa"
    "pavucontrol"
    
    # File management
    "thunar"
    "tumbler"
    "ffmpegthumbnailer"
    
    # Utilidades
    "playerctl"
    "jq"
    "socat"
    
    # Temas
    "nwg-look"
    "qt5ct"
    "qt6ct"
    "papirus-icon-theme"
    
    # Shell
    "zsh"
)

AUR_PACKAGES=(
    "hyprlock"
    "hypridle"
    "wlogout"
    "swww"
    "cliphist"
    "udiskie"
)

SERVICES_MAP=(
    "mako:mako.service"
    "hypridle:hypridle.service"
)

CHECK_PACKAGES=0

# Garantizar estructura mínima
mkdir -p \
    "$STATE_DIR" \
    "$BACKUP_DIR" \
    "$RUNTIME_DIR" \
    "$CACHE_DIR"

touch "$TOUCHED_FILE"
