#!/usr/bin/env bash

log() {
    [[ "${VERBOSE:-0}" == "1" ]] && echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

version_ge() {
    # version_ge INSTALLED REQUIRED
    [[ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}
