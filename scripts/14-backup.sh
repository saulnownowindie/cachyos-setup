#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 13
# Backup completo del sistema
###############################################################################

BACKUP_ROOT="${BACKUP_DIR:-/mnt/CACHY-BACKUP/backups}"

TARGET_USER="saul"
TARGET_HOME="/home/$TARGET_USER"
BACKUP_MAIN="$(dirname "$BACKUP_ROOT")"
USER_HOME="/home/saul"
USER_NAME="saul"
mkdir -p "$BACKUP_ROOT"


backup_dir() {

    local SRC="$1"
    local DST="$2"


    [[ -d "$SRC" ]] || return 0


    mkdir -p "$(dirname "$DST")"


    rsync -a --delete \
    "$SRC/" \
    "$DST/"


    ok "Respaldado: $SRC"

}



backup_file() {

    local SRC="$1"
    local DST="$2"


    [[ -f "$SRC" ]] || return 0


    mkdir -p "$(dirname "$DST")"


    cp -f "$SRC" "$DST"


    ok "Respaldado: $SRC"

}



echo
echo "=========================================="
echo " Backup CachyOS"
echo " Destino: $BACKUP_ROOT"
echo "=========================================="



###############################################################################
# Información sistema
###############################################################################

mkdir -p "$BACKUP_ROOT/system"


uname -a \
> "$BACKUP_ROOT/system/kernel.txt"


if command -v nvidia-smi >/dev/null; then

    nvidia-smi \
    > "$BACKUP_ROOT/system/nvidia.txt"

fi


###############################################################################
# Servicios usuario
###############################################################################

sudo -u "$USER_NAME" \
XDG_RUNTIME_DIR=/run/user/$(id -u "$USER_NAME") \
systemctl --user list-unit-files --state=enabled \
> "$BACKUP_ROOT/systemd-user-services.txt" || true



###############################################################################
# Usuario
###############################################################################

backup_dir \
"$USER_HOME/.config/fish" \
"$BACKUP_ROOT/fish"



backup_file \
"$USER_HOME/.config/starship.toml" \
"$BACKUP_ROOT/starship.toml"



###############################################################################
# Git
###############################################################################

backup_file \
"$USER_HOME/.gitconfig" \
"$BACKUP_ROOT/git/.gitconfig"



backup_dir \
"$USER_HOME/.ssh" \
"$BACKUP_ROOT/ssh"



###############################################################################
# VS Code
###############################################################################

backup_dir \
"$USER_HOME/.config/Code/User" \
"$BACKUP_ROOT/vscode/User"



if command -v code >/dev/null; then

    mkdir -p "$BACKUP_ROOT/vscode"

    sudo -u "$USER_NAME" \
    code --list-extensions \
    > "$BACKUP_ROOT/vscode/extensions.txt" || true


    ok "Extensiones VS Code guardadas."

fi



###############################################################################
# Fuentes
###############################################################################

backup_dir \
"$USER_HOME/.local/share/fonts" \
"$BACKUP_ROOT/fonts/user"



backup_dir \
"$USER_HOME/.fonts" \
"$BACKUP_ROOT/fonts/legacy"



backup_dir \
"/usr/share/fonts/custom" \
"$BACKUP_ROOT/fonts/custom"



###############################################################################
# Aplicaciones
###############################################################################

backup_dir \
"$USER_HOME/.var/app/one.ablaze.floorp" \
"$BACKUP_ROOT/browser/floorp"



backup_dir \
"$USER_HOME/.config/obs-studio" \
"$BACKUP_ROOT/obs"



backup_dir \
"$USER_HOME/.config/syncthing" \
"$BACKUP_ROOT/syncthing"



###############################################################################
# DaVinci Resolve
###############################################################################

backup_dir \
"/opt/resolve/Fusion/Scripts" \
"$BACKUP_ROOT/davinci/FusionScripts"



if [[ -d "$USER_HOME/.local/share/DaVinciResolve" ]]; then


rsync -a --delete \
--exclude="logs" \
--exclude=".cache" \
"$USER_HOME/.local/share/DaVinciResolve/" \
"$BACKUP_ROOT/davinci/database/"


ok "DaVinci respaldado."


fi



backup_dir \
"$USER_HOME/.config/DaVinciResolve" \
"$BACKUP_ROOT/davinci/config"



###############################################################################
# KDE
###############################################################################

backup_file \
"$USER_HOME/.config/kdeglobals" \
"$BACKUP_ROOT/kde/kdeglobals"



backup_file \
"$USER_HOME/.config/kwinrc" \
"$BACKUP_ROOT/kde/kwinrc"



backup_file \
"$USER_HOME/.config/kglobalshortcutsrc" \
"$BACKUP_ROOT/kde/kglobalshortcutsrc"



backup_file \
"$USER_HOME/.config/dolphinrc" \
"$BACKUP_ROOT/kde/dolphinrc"



backup_file \
"$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
"$BACKUP_ROOT/kde/plasma-org.kde.plasma.desktop-appletsrc"



backup_dir \
"$USER_HOME/.local/share/plasma" \
"$BACKUP_ROOT/kde/plasma"



backup_dir \
"$USER_HOME/.local/share/kscreen" \
"$BACKUP_ROOT/kde/kscreen"



###############################################################################
# Paquetes
###############################################################################

pacman -Qqe \
> "$BACKUP_ROOT/packages.txt" || true


pacman -Qqm \
> "$BACKUP_ROOT/aur-packages.txt" || true



###############################################################################
# Flatpaks
###############################################################################

echo "Guardando Flatpaks..."

touch "$BACKUP_ROOT/flatpaks.txt"

sudo -u "$USER_NAME" \
XDG_RUNTIME_DIR=/run/user/$(id -u "$USER_NAME") \
flatpak list --user --app --columns=application,origin \
>> "$BACKUP_ROOT/flatpaks.txt" || true


flatpak list --system --app --columns=application,origin \
>> "$BACKUP_ROOT/flatpaks.txt" || true


ok "Flatpaks guardados."
###############################################################################
# Guardar scripts de recuperación
###############################################################################

if [[ -d "$ROOT_DIR" ]]; then


rsync -a \
--exclude=".git" \
"$ROOT_DIR/" \
"$BACKUP_MAIN/cachyos-setup/"


ok "Scripts CachyOS guardados."


fi

chown -R "$USER_NAME:$USER_NAME" "$BACKUP_ROOT"

echo
echo "=========================================="
echo " Backup terminado"
echo "=========================================="



find "$BACKUP_ROOT" -maxdepth 2 | sort