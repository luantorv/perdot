# Bootstrap para perdot

Script de instalación automática para desplegar perdot en una instalación mínima de Arch Linux.

## ¿Qué hace el bootstrap?

El script `bootstrap.sh` automatiza todo el proceso de instalación, desde la preparación del sistema hasta la configuración completa del entorno Hyprland.

## Proceso paso a paso

### 1. Verificación del sistema
- Confirma que estás en Arch Linux
- Verifica que git esté instalado
- Comprueba la ubicación del repositorio

### 2. Instalación de yay
- Detecta si yay (AUR helper) está instalado
- Si no lo está, lo instala automáticamente
- Instala dependencias necesarias (base-devel)

### 3. Actualización del sistema
- Ejecuta `pacman -Syu` para actualizar todos los paquetes

### 4. Instalación de paquetes
Instala automáticamente todos los paquetes necesarios:

**Oficiales (pacman):**
- Core: hyprland, eww, rofi, mako, kitty
- Wayland: grim, slurp, swappy, wl-clipboard
- Sistema: brightnessctl, NetworkManager, polkit-gnome, blueman, udisks2
- Audio: pipewire, wireplumber, pipewire-pulse, pipewire-alsa, pavucontrol
- Archivos: thunar, tumbler, ffmpegthumbnailer
- Temas: nwg-look, qt5ct, qt6ct, papirus-icon-theme
- Shell: zsh

**AUR (yay):**
- hyprlock, hypridle, wlogout
- swww, cliphist, udiskie

### 5. Instalación de perdot
- Ejecuta `bin/perdot install`
- Instala perdot en `~/.local/bin/perdot`
- Hace perdot disponible globalmente

### 6. Setup del entorno
- Ejecuta `perdot setup`
- Crea symlinks de configuraciones
- Prepara servicios systemd de usuario

### 7. Servicios del sistema
- Habilita NetworkManager
- Habilita Bluetooth (si está disponible)

### 8. Servicios de usuario
- Habilita pipewire, pipewire-pulse, wireplumber

### 9. Directorios adicionales
- `~/Pictures/Wallpapers`
- `~/Pictures/Screenshots`
- `~/.cache/cliphist`

### 10. Configuración de shell y permisos
- Sugiere cambiar a zsh si no lo es
- Añade usuario al grupo 'input' (para brightnessctl sin sudo)

### 11. Finalización
- Muestra resumen de instalación
- Lista próximos pasos
- Ofrece cerrar sesión automáticamente

## Uso

### Requisitos previos
- Arch Linux instalado
- Git: `sudo pacman -S git`
- Conexión a internet

### Desde el repositorio clonado

```bash
git clone https://github.com/luantorv/perdot.git ~/perdot
cd ~/perdot
./bootstrap.sh
```

## Después del bootstrap

1. **Cerrar sesión** (o reiniciar)
2. **Seleccionar Hyprland** en el display manager
3. **Iniciar sesión**

### Primer inicio en Hyprland

El entorno estará completamente configurado. Atajos principales:
- `SUPER + T`: Terminal
- `SUPER`: Launcher
- `SUPER + Q`: Cerrar ventana

### Configuración opcional

```bash
# Añadir wallpapers
cp tus_wallpapers/* ~/Pictures/Wallpapers/

# Configurar temas
nwg-look
qt5ct
qt6ct
```

## Lo que NO hace el bootstrap

Siguiendo la filosofía de perdot:
- No ejecuta servicios en background
- No se queda residente en el sistema
- No modifica configuraciones existentes sin crear backups
- No toma control del sistema
- Una vez terminado, desaparece

## Comandos útiles post-instalación

```bash
# Actualizar configuraciones
perdot update

# Ver estado
perdot status

# Diagnóstico
perdot doctor
```

## Estructura respetada

El bootstrap respeta completamente la estructura de perdot:
- Usa `bin/perdot install` (no copia manualmente)
- Usa `perdot setup` (no configura manualmente)
- Respeta los mappings en `mappings/default.map`
- No toca la estructura de `files/`
- No modifica scripts internos

## Solución de problemas

### yay falla al instalar
```bash
# Instalar manualmente
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Paquetes específicos fallan
El bootstrap continúa aunque algunos paquetes fallen. Puedes instalarlos manualmente después:
```bash
yay -S paquete_que_fallo
```

### perdot no se encuentra después
```bash
# Verificar instalación
which perdot

# Si no está, reinstalar manualmente
cd ~/perdot
ln -sf bin/perdot ~/.local/bin
sudo chmod +x ~/perdot/bin/perdot
```

## Compatibilidad

- **Diseñado para**: Arch Linux limpio
- **Puede causar problemas en**: Arch-based distros o sistemas con configs existentes

## Filosofía

El bootstrap sigue la filosofía de perdot:
- Simple y directo
- No intrusivo
- Fácil de remover
- No crea dependencias permanentes
- El sistema funciona sin él una vez terminado

## Autor

Este bootstrap es parte del proyecto perdot:
- Autor: Reis Viera, Luis
- GitHub: [@luantorv](https://github.com/luantorv/)
- Repositorio: https://github.com/luantorv/perdot
