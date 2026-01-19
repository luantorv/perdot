#!/bin/bash
#
# Bootstrap script para perdot
# Instalación automática desde una instalación mínima de Arch Linux
#
# Uso: ./bootstrap.sh
#

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/perdot}"

# Banner
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                  PERDOT BOOTSTRAP                         ║
║            Arch Linux dotfiles installer                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Funciones
log() {
    echo -e "${GREEN}==>${NC} $1"
}

warn() {
    echo -e "${YELLOW}==>${NC} $1"
}

error() {
    echo -e "${RED}==>${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}==>${NC} $1"
}

# Verificar que estamos en Arch Linux
if [ ! -f /etc/arch-release ]; then
    error "Este script está diseñado para Arch Linux"
fi

# Verificar que tenemos git
if ! command -v git &> /dev/null; then
    error "Git no está instalado. Instala con: sudo pacman -S git"
fi

log "Iniciando bootstrap de perdot..."
echo

# Paso 1: Verificar/mover repositorio si es necesario
if [ "$SCRIPT_DIR" != "$DOTFILES_ROOT" ]; then
    if [ -d "$DOTFILES_ROOT" ]; then
        warn "El directorio $DOTFILES_ROOT ya existe"
        echo -e "${YELLOW}¿Deseas sobrescribirlo? [y/N]${NC}"
        read -r -n 1 response
        echo
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            error "Abortado por el usuario"
        fi
        rm -rf "$DOTFILES_ROOT"
    fi
    
    info "Copiando repositorio a $DOTFILES_ROOT..."
    cp -r "$SCRIPT_DIR" "$DOTFILES_ROOT"
    cd "$DOTFILES_ROOT"
else
    info "Ya estamos en $DOTFILES_ROOT"
    cd "$DOTFILES_ROOT"
fi

echo

# Paso 2: Verificar/instalar yay
log "Verificando yay..."
if ! command -v yay &> /dev/null; then
    warn "yay no está instalado. Instalando..."
    
    sudo pacman -S --needed --noconfirm git base-devel
    
    TEMP_YAY="/tmp/yay-install-$$"
    git clone https://aur.archlinux.org/yay.git "$TEMP_YAY"
    cd "$TEMP_YAY"
    makepkg -si --noconfirm
    cd "$DOTFILES_ROOT"
    rm -rf "$TEMP_YAY"
    
    info "yay instalado"
else
    info "yay ya está instalado"
fi

echo

# Paso 3: Actualizar sistema
log "Actualizando sistema base..."
sudo pacman -Syu --noconfirm

echo

# Paso 4: Instalar paquetes necesarios
log "Instalando paquetes necesarios..."

# Paquetes oficiales
PACMAN_PKGS=(
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

info "Instalando paquetes oficiales..."
for pkg in "${PACMAN_PKGS[@]}"; do
    if pacman -Q "$pkg" &> /dev/null; then
        echo "  ✓ $pkg"
    else
        echo "  → Instalando $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg" || warn "Falló instalación de $pkg"
    fi
done

# Paquetes AUR
AUR_PKGS=(
    "hyprlock"
    "hypridle"
    "wlogout"
    "swww"
    "cliphist"
    "udiskie"
)

info "Instalando paquetes AUR..."
for pkg in "${AUR_PKGS[@]}"; do
    if pacman -Q "$pkg" &> /dev/null; then
        echo "  ✓ $pkg"
    else
        echo "  → Instalando $pkg..."
        yay -S --needed --noconfirm "$pkg" || warn "Falló instalación de $pkg"
    fi
done

echo

# Paso 5: Instalar perdot
log "Instalando perdot..."

"$DOTFILES_ROOT/bin/perdot" install

echo

# Paso 6: Setup de perdot
log "Configurando entorno con perdot..."

perdot setup

echo

# Paso 7: Habilitar servicios del sistema
log "Habilitando servicios del sistema..."

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth 2>/dev/null || warn "Bluetooth no disponible"

echo

# Paso 8: Habilitar servicios de usuario
log "Habilitando servicios de usuario..."

systemctl --user enable --now pipewire pipewire-pulse wireplumber

echo

# Paso 9: Crear directorios adicionales
log "Creando directorios adicionales..."

mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.cache/cliphist

info "Directorios creados"

echo

# Paso 10: Configurar shell
log "Configuración de shell..."

if command -v zsh &> /dev/null; then
    if [ "$SHELL" != "$(which zsh)" ]; then
        warn "Para usar zsh como shell predeterminado, ejecuta: chsh -s $(which zsh)"
    else
        info "zsh ya es tu shell predeterminado"
    fi
fi

echo

# Paso 11: Grupos de usuario
log "Verificando grupos de usuario..."

if ! groups | grep -q input; then
    warn "Añadiendo usuario al grupo 'input' (para brightnessctl)..."
    sudo usermod -aG input "$USER"
    info "Necesitarás cerrar sesión para que el cambio surta efecto"
fi

echo

# Resumen final
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}║             INSTALACIÓN COMPLETADA                        ║${NC}"
echo -e "${CYAN}║                                                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

log "perdot está listo para usar"
echo

info "Próximos pasos:"
echo "  1. Cerrar sesión y volver a iniciar"
echo "  2. Seleccionar 'Hyprland' en tu display manager"
echo "  3. (Opcional) Añadir wallpapers a ~/Pictures/Wallpapers"
echo "  4. (Opcional) Configurar temas: nwg-look, qt5ct, qt6ct"
echo

warn "Comandos útiles:"
echo "  perdot update   # Actualizar configuraciones"
echo "  perdot status   # Ver estado"
echo "  perdot doctor   # Diagnóstico"
echo

info "Documentación en: $DOTFILES_ROOT/docs/"
echo

# Preguntar si quiere cerrar sesión
echo -e "${YELLOW}¿Deseas cerrar sesión ahora? [y/N]${NC}"
read -r -n 1 response
echo

if [[ "$response" =~ ^[Yy]$ ]]; then
    log "Cerrando sesión..."
    sleep 2
    if command -v loginctl &> /dev/null; then
        loginctl terminate-user "$USER"
    else
        warn "Cierra sesión manualmente"
    fi
else
    info "Recuerda cerrar sesión para aplicar todos los cambios"
fi

echo
log "Bootstrap finalizado"
