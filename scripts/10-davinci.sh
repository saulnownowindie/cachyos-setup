#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 10
# DaVinci Resolve Studio
###############################################################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INSTALLER="$ROOT/installers/DaVinci_Resolve_Studio.run"
DAVINCI_BACKUP="${DAVINCI_BACKUP:-$ROOT/backups/davinci}"
info(){ echo -e "\033[1;34m[INFO]\033[0m $1"; }
ok(){ echo -e "\033[1;32m[ OK ]\033[0m $1"; }
warn(){ echo -e "\033[1;33m[WARN]\033[0m $1"; }
err(){ echo -e "\033[1;31m[FAIL]\033[0m $1"; }

sudo -v

info "Verificando NVIDIA..."

if ! command -v nvidia-smi >/dev/null; then
    err "No se detectó NVIDIA."
    exit 1
fi

ok "NVIDIA detectada."

info "Instalando dependencias..."

sudo pacman -S --needed --noconfirm \
fuse2 \
apr \
apr-util \
python \
python-pip \
ffmpeg \
gst-libav \
gst-plugins-good \
gst-plugins-bad \
gst-plugins-ugly \
qt6-wayland

if [[ ! -f "$INSTALLER" ]]; then

    warn "DaVinci Resolve no instalado."
    warn "No se encontró el instalador:"
    echo "      $INSTALLER"
    warn "El módulo continuará sin instalar DaVinci."

    echo
    echo "=========================================="
    echo " 10-davinci.sh completado (omitido)"
    echo "=========================================="

    exit 0

fi

chmod +x "$INSTALLER"

if [[ ! -d /opt/resolve ]]; then
    info "Instalando DaVinci Resolve Studio..."
    sudo SKIP_PACKAGE_CHECK=1 "$INSTALLER"
else
    warn "DaVinci Resolve ya está instalado."
fi

mkdir -p "$HOME/.local/share/DaVinciResolve"

if [[ -d "$DAVINCI_BACKUP" ]]; then
    info "Restaurando configuración de DaVinci Resolve..."

    mkdir -p "$HOME/.local/share/DaVinciResolve"

rsync -a "$DAVINCI_BACKUP/database/" \
"$HOME/.local/share/DaVinciResolve/"

    cp -a "$DAVINCI_BACKUP/config/." \
    "$HOME/.local/share/DaVinciResolve/" || true

    ok "Configuración de DaVinci restaurada."
fi
if [[ -d "$DAVINCI_BACKUP/FusionScripts" && -d /opt/resolve ]]; then

    info "Restaurando Fusion Scripts..."

    sudo mkdir -p /opt/resolve/Fusion/Scripts

    sudo rsync -a "$DAVINCI_BACKUP/FusionScripts/" \
    /opt/resolve/Fusion/Scripts/

    ok "Fusion Scripts restaurados."
fi


if [[ -f /usr/share/applications/com.blackmagicdesign.resolve.desktop ]]; then
    ok "Acceso directo detectado."
elif [[ -f /opt/resolve/bin/resolve ]]; then
    cat > "$HOME/.local/share/applications/davinci-resolve.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=DaVinci Resolve Studio
Exec=/opt/resolve/bin/resolve
Icon=/opt/resolve/graphics/DV_Resolve.png
Categories=AudioVideo;
Terminal=false
EOF
fi

echo
echo "=========================================="
echo " DaVinci Resolve Studio"
echo "=========================================="
echo
echo "Estado:"
echo "  Instalador : $INSTALLER"
echo "  Programa   : /opt/resolve"
echo "  Config     : ~/.local/share/DaVinciResolve"
echo
echo "Restaurado:"
echo " - Configuración de DaVinci Resolve"
echo " - Biblioteca de proyectos"
echo " - Fusion Scripts"
echo " - Preferencias del usuario"
