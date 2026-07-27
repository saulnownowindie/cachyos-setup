#!/usr/bin/env bash
set -Eeuo pipefail

###############################################################################
# CachyOS Setup - Módulo 10
# DaVinci Resolve Studio
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"


INSTALLER="$ROOT_DIR/installers/DaVinci_Resolve_Studio.run"

DAVINCI_BACKUP="${DAVINCI_BACKUP:-}"



###############################################################################
# Verificar NVIDIA
###############################################################################

info "Verificando NVIDIA..."

if ! command -v nvidia-smi >/dev/null 2>&1; then

    warn "No se detectó NVIDIA."

else

    ok "NVIDIA detectada."

fi



###############################################################################
# Dependencias
###############################################################################

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



###############################################################################
# Instalar DaVinci
###############################################################################

if [[ ! -f "$INSTALLER" ]]; then

    warn "No existe instalador DaVinci:"
    echo "$INSTALLER"

else


    chmod +x "$INSTALLER"


    if [[ ! -d /opt/resolve ]]; then


        echo
        echo "Instalando DaVinci Resolve Studio..."

        sudo env SKIP_PACKAGE_CHECK=1 \
        "$INSTALLER"


        ok "DaVinci instalado"


    else

        ok "DaVinci ya estaba instalado"

    fi

fi



###############################################################################
# Restaurar configuración
###############################################################################

if [[ -n "$DAVINCI_BACKUP" ]] && [[ -d "$DAVINCI_BACKUP" ]]; then


    echo
    echo "Restaurando configuración DaVinci..."



    mkdir -p \
    "$HOME/.local/share/DaVinciResolve"



    # Base / proyectos

    if [[ -d "$DAVINCI_BACKUP/database" ]]; then


        rsync -a \
        "$DAVINCI_BACKUP/database/" \
        "$HOME/.local/share/DaVinciResolve/"


    fi



    # Configuración antigua

    if [[ -d "$DAVINCI_BACKUP/DaVinciResolve" ]]; then


        rsync -a \
        "$DAVINCI_BACKUP/DaVinciResolve/" \
        "$HOME/.local/share/DaVinciResolve/"


    fi



    chown -R \
    "$USER:$USER" \
    "$HOME/.local/share/DaVinciResolve"



    ok "Configuración DaVinci restaurada"


fi



###############################################################################
# Fusion Scripts
###############################################################################

if [[ -d "$DAVINCI_BACKUP/FusionScripts" ]]; then


    echo
    echo "Restaurando Fusion Scripts..."


    sudo mkdir -p \
    /opt/resolve/Fusion/Scripts



    sudo rsync -a \
    "$DAVINCI_BACKUP/FusionScripts/" \
    /opt/resolve/Fusion/Scripts/



    ok "Fusion Scripts restaurados"


fi



###############################################################################
# Acceso directo
###############################################################################

DESKTOP="$HOME/.local/share/applications/davinci-resolve.desktop"


if [[ ! -f "$DESKTOP" ]] && [[ -x /opt/resolve/bin/resolve ]]; then


mkdir -p "$(dirname "$DESKTOP")"


cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=DaVinci Resolve Studio
Exec=/opt/resolve/bin/resolve
Icon=/opt/resolve/graphics/DV_Resolve.png
Categories=AudioVideo;
Terminal=false
StartupWMClass=resolve
EOF


chmod +x "$DESKTOP"


fi



###############################################################################
# Verificación
###############################################################################

echo

if [[ -x /opt/resolve/bin/resolve ]]; then

    ok "DaVinci Resolve listo"

else

    warn "DaVinci Resolve no encontrado"

fi



echo
echo "=========================================="
echo " DaVinci Resolve Studio"
echo "=========================================="

echo "Instalador:"
echo "$INSTALLER"

echo "Programa:"
echo "/opt/resolve"

echo
