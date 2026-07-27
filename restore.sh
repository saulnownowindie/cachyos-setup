#!/usr/bin/env bash
set -Eeuo pipefail

BACKUPS="${1:-}"
USER_HOME="/home/saul"
USER_NAME="saul"
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
"$USER_HOME/.config/fish"

copyfile "$BACKUPS/starship.toml" \
"$USER_HOME/.config/starship.toml"


# Git
copyfile "$BACKUPS/git/.gitconfig" \
"$USER_HOME/.gitconfig"


# VS Code
copydir "$BACKUPS/vscode/User" \
"$USER_HOME/.config/Code/User"


# Floorp
copydir "$BACKUPS/browser/floorp" \
"$USER_HOME/.var/app/one.ablaze.floorp"


# Syncthing
copydir "$BACKUPS/syncthing" \
"$USER_HOME/.config/syncthing"

# Activar servicios de usuario
if [[ -f "$BACKUPS/systemd-user-services.txt" ]]; then

    echo "Restaurando servicios de usuario..."

    while read -r SERVICE _; do

        [[ -z "$SERVICE" ]] && continue

        sudo -u "$USER_NAME" \
        XDG_RUNTIME_DIR=/run/user/$(id -u "$USER_NAME") \
        systemctl --user enable --now "$SERVICE" || true

    done < "$BACKUPS/systemd-user-services.txt"

fi


# OBS
copydir "$BACKUPS/obs" \
"$USER_HOME/.config/obs-studio"


# SSH
copydir "$BACKUPS/ssh" \
"$USER_HOME/.ssh"

chmod 700 "$USER_HOME/.ssh" 2>/dev/null || true


# KDE
copyfile "$BACKUPS/kde/kdeglobals" \
"$USER_HOME/.config/kdeglobals"

copyfile "$BACKUPS/kde/kwinrc" \
"$USER_HOME/.config/kwinrc"

copyfile "$BACKUPS/kde/kglobalshortcutsrc" \
"$USER_HOME/.config/kglobalshortcutsrc"

copyfile "$BACKUPS/kde/dolphinrc" \
"$USER_HOME/.config/dolphinrc"

copyfile "$BACKUPS/kde/plasma-org.kde.plasma.desktop-appletsrc" \
"$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

copydir "$BACKUPS/kde/plasma" \
"$USER_HOME/.local/share/plasma"

copydir "$BACKUPS/kde/kscreen" \
"$USER_HOME/.local/share/kscreen"



# DaVinci Resolve
copydir "$BACKUPS/davinci/database" \
"$USER_HOME/.local/share/DaVinciResolve"

copydir "$BACKUPS/davinci/config" \
"$USER_HOME/.config/DaVinciResolve"


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

    mkdir -p "$USER_HOME/.local/share/fonts"

    rsync -a \
    "$BACKUPS/fonts/user/" \
    "$USER_HOME/.local/share/fonts/"

    echo "Restauradas fuentes de usuario."

fi


# Fuentes legacy
if [[ -d "$BACKUPS/fonts/legacy" ]]; then

    mkdir -p "$USER_HOME/.fonts"

    rsync -a \
    "$BACKUPS/fonts/legacy/" \
    "$USER_HOME/.fonts/"

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

   sudo -u "$USER_NAME" fc-cache -fv || true
  sudo fc-cache -f -v || true

fi

echo "Corrigiendo permisos de usuario..."

chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config" 2>/dev/null || true
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.local" 2>/dev/null || true
chown "$USER_NAME:$USER_NAME" "$USER_HOME" 2>/dev/null || true
chown "$USER_NAME:$USER_NAME" "$USER_HOME/.gitconfig" 2>/dev/null || true
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.ssh" 2>/dev/null || true
echo
echo "================================"
echo " Restauración finalizada"
echo "================================"