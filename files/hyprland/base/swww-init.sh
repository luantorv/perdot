#!/bin/bash

# Iniciar swww daemon
swww-daemon &

# Esperar a que el daemon esté listo
sleep 1

# Directorio de wallpapers (cambiar según preferencia)
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Si existe el directorio, usar un wallpaper aleatorio
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        swww img "$WALLPAPER" --transition-type wipe --transition-fps 60
    fi
else
    # Color sólido por defecto si no hay wallpapers
    swww img --color "#1a1b26"
fi
