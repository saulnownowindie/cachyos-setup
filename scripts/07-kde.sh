#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 07
# KDE Plasma
###############################################################################

info(){
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

sudo -v


###############################################################################
# KDE paquetes
###############################################################################

info "Instalando utilidades KDE..."

sudo pacman -S --needed --noconfirm \
ark \
dolphin \
dolphin-plugins \
gwenview \
okular \
kate \
spectacle \
filelight \
partitionmanager \
kcalc \
kruler \
kdeconnect \
plasma-firewall \
ffmpegthumbs \
kdecoration

###############################################################################
# Servicios
###############################################################################

info "Habilitando servicios..."

systemctl --user enable kdeconnectd.service >/dev/null 2>&1 || true


###############################################################################
# Configuración KDE
###############################################################################

info "Aplicando configuración KDE..."


kwriteconfig6 \
--file kdeglobals \
--group KDE \
--key SingleClick false || true


kwriteconfig6 \
--file kdeglobals \
--group General \
--key BrowserApplication floorp.desktop || true


kwriteconfig6 \
--file dolphinrc \
--group General \
--key RememberOpenedTabs true || true


kwriteconfig6 \
--file dolphinrc \
--group General \
--key ConfirmClosingMultipleTabs false || true


kwriteconfig6 \
--file kwinrc \
--group Windows \
--key BorderlessMaximizedWindows false || true

###############################################################################
# Restaurar archivos Darkly del backup si existen
###############################################################################

BACKUP_DARKLY="$HOME/.cache/cachyos-setup/Darkly"

if [[ -d "$BACKUP_DARKLY" ]]; then

    info "Darkly encontrado en cache."

fi


###############################################################################
# Recargar KDE
###############################################################################

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true


echo
echo "======================================"
echo " KDE configurado"
echo "======================================"
echo
echo "Aplicado:"
echo "- KDE Plasma"
echo "- Doble clic"
echo "- Floorp navegador"
echo "- Dolphin recuerda pestañas"
echo "- KDE Connect"
echo
