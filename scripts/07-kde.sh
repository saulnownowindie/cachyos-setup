#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 07
# KDE Plasma
###############################################################################

info(){ echo -e "\033[1;34m[INFO]\033[0m $1"; }

sudo -v

info "Instalando utilidades KDE..."

sudo pacman -S --needed --noconfirm \
ark dolphin dolphin-plugins \
gwenview okular kate \
spectacle filelight \
partitionmanager \
kcalc kruler \
kdeconnect \
plasma-firewall \
ffmpegthumbs

info "Habilitando servicios..."

systemctl --user enable kdeconnectd.service >/dev/null 2>&1 || true

kwriteconfig6 --file kdeglobals \
--group KDE \
--key SingleClick false || true

kwriteconfig6 --file kdeglobals \
--group General \
--key BrowserApplication floorp.desktop || true

kwriteconfig6 --file dolphinrc \
--group General \
--key RememberOpenedTabs true || true

kwriteconfig6 --file dolphinrc \
--group General \
--key ConfirmClosingMultipleTabs false || true

kwriteconfig6 --file kwinrc \
--group Windows \
--key BorderlessMaximizedWindows false || true

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true

echo
echo "======================================"
echo " KDE configurado"
echo "======================================"
echo
echo "Configuraciones aplicadas:"
echo "- Doble clic"
echo "- Floorp como navegador"
echo "- Dolphin recuerda pestañas"
echo "- Sin borde en maximizadas desactivado"
echo "- KDE Connect habilitado"
