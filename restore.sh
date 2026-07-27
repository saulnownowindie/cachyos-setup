#!/usr/bin/env bash
set -Eeuo pipefail


###############################################################################
# CachyOS Setup
# Restauración de configuración de usuario
###############################################################################

BACKUPS="${1:-}"

USER_NAME="saul"
USER_HOME="/home/$USER_NAME"


if [[ -z "$BACKUPS" ]]; then

    echo "Uso:"
    echo "./restore.sh /ruta/al/backup"

    exit 1

fi



###############################################################################
# Funciones
###############################################################################

copydir(){

    local SRC="$1"
    local DST="$2"


    [[ -d "$SRC" ]] || return 0


    mkdir -p "$DST"


    rsync -a \
    "$SRC/" \
    "$DST/"


    echo "[ OK ] $DST"

}



copyfile(){

    local SRC="$1"
    local DST="$2"


    [[ -f "$SRC" ]] || return 0


    mkdir -p "$(dirname "$DST")"


    cp -f \
    "$SRC" \
    "$DST"


    echo "[ OK ] $DST"

}



###############################################################################
# Inicio
###############################################################################

echo
echo "================================"
echo " Restaurando CachyOS"
echo "================================"



###############################################################################
# Fish
###############################################################################

copydir \
"$BACKUPS/fish" \
"$USER_HOME/.config/fish"



copyfile \
"$BACKUPS/starship.toml" \
"$USER_HOME/.config/starship.toml"



###############################################################################
# Git
###############################################################################

copyfile \
"$BACKUPS/git/.gitconfig" \
"$USER_HOME/.gitconfig"



###############################################################################
# VS Code
###############################################################################

copydir \
"$BACKUPS/vscode/User" \
"$USER_HOME/.config/Code/User"



###############################################################################
# Floorp Flatpak
###############################################################################

copydir \
"$BACKUPS/browser/floorp" \
"$USER_HOME/.var/app/one.ablaze.floorp"



###############################################################################
# OBS
###############################################################################

copydir \
"$BACKUPS/obs" \
"$USER_HOME/.config/obs-studio"



###############################################################################
# Syncthing
###############################################################################

copydir \
"$BACKUPS/syncthing" \
"$USER_HOME/.config/syncthing"



###############################################################################
# SSH
###############################################################################

echo
echo "Restaurando SSH..."



if [[ -d "$BACKUPS/ssh" ]]; then


    mkdir -p "$USER_HOME/.ssh"


    rsync -a \
    "$BACKUPS/ssh/" \
    "$USER_HOME/.ssh/"



    chown -R \
    "$USER_NAME:$USER_NAME" \
    "$USER_HOME/.ssh"



    chmod 700 \
    "$USER_HOME/.ssh"



    [[ -f "$USER_HOME/.ssh/id_ed25519" ]] && \
    chmod 600 "$USER_HOME/.ssh/id_ed25519"



    [[ -f "$USER_HOME/.ssh/config" ]] && \
    chmod 600 "$USER_HOME/.ssh/config"



    [[ -f "$USER_HOME/.ssh/id_ed25519.pub" ]] && \
    chmod 644 "$USER_HOME/.ssh/id_ed25519.pub"



    [[ -f "$USER_HOME/.ssh/known_hosts" ]] && \
    chmod 644 "$USER_HOME/.ssh/known_hosts"



    echo "[ OK ] SSH restaurado"

fi



###############################################################################
# KDE
###############################################################################

copyfile \
"$BACKUPS/kde/kdeglobals" \
"$USER_HOME/.config/kdeglobals"



copyfile \
"$BACKUPS/kde/kwinrc" \
"$USER_HOME/.config/kwinrc"



copyfile \
"$BACKUPS/kde/kglobalshortcutsrc" \
"$USER_HOME/.config/kglobalshortcutsrc"



copyfile \
"$BACKUPS/kde/dolphinrc" \
"$USER_HOME/.config/dolphinrc"



copyfile \
"$BACKUPS/kde/plasma-org.kde.plasma.desktop-appletsrc" \
"$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"



copydir \
"$BACKUPS/kde/plasma" \
"$USER_HOME/.local/share/plasma"



copydir \
"$BACKUPS/kde/kscreen" \
"$USER_HOME/.local/share/kscreen"



###############################################################################
# DaVinci
###############################################################################

copydir \
"$BACKUPS/davinci/database" \
"$USER_HOME/.local/share/DaVinciResolve"



copydir \
"$BACKUPS/davinci/DaVinciResolve" \
"$USER_HOME/.local/share/DaVinciResolve"



###############################################################################
# Fusion Scripts
###############################################################################

if [[ -d "$BACKUPS/davinci/FusionScripts" ]]; then


    sudo mkdir -p \
    /opt/resolve/Fusion/Scripts



    sudo rsync -a \
    "$BACKUPS/davinci/FusionScripts/" \
    /opt/resolve/Fusion/Scripts/


fi



###############################################################################
# Fuentes
###############################################################################

echo
echo "Restaurando fuentes..."



copydir \
"$BACKUPS/fonts/user" \
"$USER_HOME/.local/share/fonts"



if [[ -d "$BACKUPS/fonts/custom" ]]; then


    sudo mkdir -p \
    /usr/share/fonts/custom


    sudo rsync -a \
    "$BACKUPS/fonts/custom/" \
    /usr/share/fonts/custom/


fi



if [[ -d "$BACKUPS/fonts/legacy" ]]; then


    copydir \
    "$BACKUPS/fonts/legacy" \
    "$USER_HOME/.fonts"


fi



###############################################################################
# Permisos usuario
###############################################################################

echo
echo "Corrigiendo permisos..."



chown -R \
"$USER_NAME:$USER_NAME" \
"$USER_HOME/.config" \
2>/dev/null || true



chown -R \
"$USER_NAME:$USER_NAME" \
"$USER_HOME/.local" \
2>/dev/null || true



chown \
"$USER_NAME:$USER_NAME" \
"$USER_HOME/.gitconfig" \
2>/dev/null || true



###############################################################################
# Cache fuentes
###############################################################################

echo
echo "Actualizando fuentes..."



sudo -u "$USER_NAME" \
fc-cache -f



sudo fc-cache -f



###############################################################################
# Final
###############################################################################

echo
echo "================================"
echo " Restauración finalizada"
echo "================================"
