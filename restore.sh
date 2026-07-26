#!/usr/bin/env bash
set -Eeuo pipefail

BACKUPS="${1:-}"

if [[ -z "$BACKUPS" ]]; then
    echo "Uso:"
    echo "./restore.sh /ruta/al/backup"
    exit 1
fi


copydir(){
    SRC="$1"
    DST="$2"

    [[ -d "$SRC" ]] || return 0

    mkdir -p "$DST"

    rsync -a "$SRC/" "$DST/"

    echo "Restaurado: $DST"
}


copyfile(){
    SRC="$1"
    DST="$2"

    [[ -f "$SRC" ]] || return 0

    mkdir -p "$(dirname "$DST")"

    cp -f "$SRC" "$DST"

    echo "Restaurado: $DST"
}


echo "================================"
echo " Restaurando CachyOS"
echo "================================"


# Shell
copydir "$BACKUPS/fish" \
"$HOME/.config/fish"

copyfile "$BACKUPS/starship.toml" \
"$HOME/.config/starship.toml"


# Git
copyfile "$BACKUPS/git/.gitconfig" \
"$HOME/.gitconfig"


# VS Code
copydir "$BACKUPS/vscode/User" \
"$HOME/.config/Code/User"


# Floorp
copydir "$BACKUPS/browser/floorp" \
"$HOME/.var/app/one.ablaze.floorp"


# Syncthing
copydir "$BACKUPS/syncthing" \
"$HOME/.config/syncthing"


# OBS
copydir "$BACKUPS/obs" \
"$HOME/.config/obs-studio"


# SSH
copydir "$BACKUPS/ssh" \
"$HOME/.ssh"

chmod 700 "$HOME/.ssh" 2>/dev/null || true


# KDE
copyfile "$BACKUPS/kde/kdeglobals" \
"$HOME/.config/kdeglobals"

copyfile "$BACKUPS/kde/kwinrc" \
"$HOME/.config/kwinrc"

copyfile "$BACKUPS/kde/kglobalshortcutsrc" \
"$HOME/.config/kglobalshortcutsrc"

copyfile "$BACKUPS/kde/dolphinrc" \
"$HOME/.config/dolphinrc"

copyfile "$BACKUPS/kde/plasma-org.kde.plasma.desktop-appletsrc" \
"$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

copydir "$BACKUPS/kde/plasma" \
"$HOME/.local/share/plasma"

copydir "$BACKUPS/kde/kscreen" \
"$HOME/.local/share/kscreen"



# DaVinci Resolve
copydir "$BACKUPS/davinci/database" \
"$HOME/.local/share/DaVinciResolve"

copydir "$BACKUPS/davinci/config" \
"$HOME/.config/DaVinciResolve"


if [[ -d "$BACKUPS/davinci/FusionScripts" ]]; then

    sudo mkdir -p /opt/resolve/Fusion/Scripts

    sudo rsync -a \
    "$BACKUPS/davinci/FusionScripts/" \
    /opt/resolve/Fusion/Scripts/

    echo "Restaurado: Fusion Scripts"

fi

###############################################################################
# Fuentes
###############################################################################

# Fuentes del usuario
if [[ -d "$BACKUPS/fonts/user" ]]; then

    mkdir -p "$HOME/.local/share/fonts"

    rsync -a \
    "$BACKUPS/fonts/user/" \
    "$HOME/.local/share/fonts/"

    echo "Restauradas fuentes de usuario."

fi


# Fuentes legacy
if [[ -d "$BACKUPS/fonts/legacy" ]]; then

    mkdir -p "$HOME/.fonts"

    rsync -a \
    "$BACKUPS/fonts/legacy/" \
    "$HOME/.fonts/"

    echo "Restauradas fuentes legacy."

fi


# Fuentes del sistema personalizadas
if [[ -d "$BACKUPS/fonts/custom" ]]; then

    echo "Restaurando fuentes del sistema..."

    sudo mkdir -p /usr/share/fonts/custom

    sudo rsync -a \
    "$BACKUPS/fonts/custom/" \
    /usr/share/fonts/custom/

    echo "Restauradas fuentes custom."

fi


# Reconstruir caché
if command -v fc-cache >/dev/null; then

    fc-cache -fv || true
    sudo fc-cache -f -v || true

fi


echo
echo "================================"
echo " Restauración finalizada"
echo "================================"