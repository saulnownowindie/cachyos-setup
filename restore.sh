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

    local SRC="$1"
    local DST="$2"

    [[ -d "$SRC" ]] || return 0

    mkdir -p "$DST"

    rsync -a "$SRC/" "$DST/"

    echo "Restaurado: $DST"

}


copyfile(){

    local SRC="$1"
    local DST="$2"

    [[ -f "$SRC" ]] || return 0

    mkdir -p "$(dirname "$DST")"

    cp -f "$SRC" "$DST"

    echo "Restaurado: $DST"

}



echo "================================"
echo " Restaurando CachyOS"
echo "================================"



###############################################################################
# Usuario
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
# Floorp
###############################################################################

copydir \
"$BACKUPS/browser/floorp" \
"$USER_HOME/.var/app/one.ablaze.floorp"



###############################################################################
# Syncthing
###############################################################################

copydir \
"$BACKUPS/syncthing" \
"$USER_HOME/.config/syncthing"



###############################################################################
# OBS
###############################################################################

copydir \
"$BACKUPS/obs" \
"$USER_HOME/.config/obs-studio"



###############################################################################
# SSH
###############################################################################

if [[ -d "$BACKUPS/ssh" ]]; then

    echo "Restaurando SSH..."

    mkdir -p "$USER_HOME/.ssh"

    rsync -a \
    "$BACKUPS/ssh/" \
    "$USER_HOME/.ssh/"

    chown -R "$USER_NAME:$USER_NAME" \
    "$USER_HOME/.ssh"

    chmod 700 \
    "$USER_HOME/.ssh"


    find "$USER_HOME/.ssh" \
    -type f \
    ! -name "*.pub" \
    -exec chmod 600 {} \;


    find "$USER_HOME/.ssh" \
    -name "*.pub" \
    -exec chmod 644 {} \;


    [[ -f "$USER_HOME/.ssh/known_hosts" ]] &&
    chmod 644 "$USER_HOME/.ssh/known_hosts"


    [[ -f "$USER_HOME/.ssh/config" ]] &&
    chmod 600 "$USER_HOME/.ssh/config"


    echo "SSH restaurado."

fi



###############################################################################
# KDE
###############################################################################

copyfile "$BACKUPS/kde/kdeglobals" \
"$USER_HOME/.config/kdeglobals"


copyfile "$BACKUPS/kde/kwinrc" \
"$USER_HOME/.config/kwinrc"


copyfile "$BACKUPS/kde/kglobalshortcutsrc" \
"$USER_HOME/.config/kglobalshortcutsrc"


copyfile "$BACKUPS/kde/dolphinrc" \
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
# DaVinci Resolve
###############################################################################

copydir \
"$BACKUPS/davinci/database" \
"$USER_HOME/.local/share/DaVinciResolve"


copydir \
"$BACKUPS/davinci/config" \
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

if [[ -d "$BACKUPS/fonts/user" ]]; then

    mkdir -p "$USER_HOME/.local/share/fonts"

    rsync -a \
    "$BACKUPS/fonts/user/" \
    "$USER_HOME/.local/share/fonts/"

fi


if [[ -d "$BACKUPS/fonts/legacy" ]]; then

    mkdir -p "$USER_HOME/.fonts"

    rsync -a \
    "$BACKUPS/fonts/legacy/" \
    "$USER_HOME/.fonts/"

fi


if [[ -d "$BACKUPS/fonts/custom" ]]; then

    sudo mkdir -p /usr/share/fonts/custom

    sudo rsync -a \
    "$BACKUPS/fonts/custom/" \
    /usr/share/fonts/custom/

fi



###############################################################################
# Activar servicios de usuario
if [[ -f "$BACKUPS/systemd-user-services.txt" ]]; then

    echo "Restaurando servicios..."

    while read -r SERVICE STATE; do

        [[ "$SERVICE" == "UNIT" ]] && continue
        [[ -z "$SERVICE" ]] && continue

        if systemctl --user list-unit-files "$SERVICE" >/dev/null 2>&1; then

            sudo -u "$USER_NAME" \
            XDG_RUNTIME_DIR=/run/user/$(id -u "$USER_NAME") \
            systemctl --user enable --now "$SERVICE" || true

        fi

    done < "$BACKUPS/systemd-user-services.txt"

fi



###############################################################################
# Permisos finales
###############################################################################

echo "Corrigiendo permisos..."


chown -R "$USER_NAME:$USER_NAME" \
"$USER_HOME/.config" 2>/dev/null || true


chown -R "$USER_NAME:$USER_NAME" \
"$USER_HOME/.local" 2>/dev/null || true


chown "$USER_NAME:$USER_NAME" \
"$USER_HOME/.gitconfig" 2>/dev/null || true


chown "$USER_NAME:$USER_NAME" \
"$USER_HOME" 2>/dev/null || true



###############################################################################
# Fuentes cache
###############################################################################

echo "Actualizando fuentes..."

sudo -u "$USER_NAME" fc-cache -f || true

sudo fc-cache -f || true



echo
echo "================================"
echo " Restauración finalizada"
echo "================================"