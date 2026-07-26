#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 08
# Syncthing
###############################################################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$ROOT/configs/syncthing"

info(){ echo -e "\033[1;34m[INFO]\033[0m $1"; }
ok(){ echo -e "\033[1;32m[ OK ]\033[0m $1"; }

sudo -v

sudo pacman -S --needed --noconfirm syncthing

systemctl --user enable syncthing.service
systemctl --user start syncthing.service

mkdir -p "$HOME/.local/state/syncthing"

if [[ -d "$BACKUP" ]]; then
    info "Restaurando configuración..."
    cp -rf "$BACKUP/"* "$HOME/.local/state/syncthing/" 2>/dev/null || true
    systemctl --user restart syncthing.service
    ok "Configuración restaurada."
else
    info "No existe respaldo en:"
    echo "  $BACKUP"
    echo
    echo "Se iniciará Syncthing con una configuración nueva."
fi

mkdir -p "$HOME/Sync"

echo
echo "======================================"
echo " Syncthing"
echo "======================================"
echo
echo "Interfaz web:"
echo "http://127.0.0.1:8384"
echo
echo "Carpeta base:"
echo "$HOME/Sync"
echo
echo "Cuando tengas una configuración definitiva,"
echo "guárdala en:"
echo "configs/syncthing/"
