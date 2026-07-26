#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 13
# Backup del entorno
###############################################################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT/backups"

mkdir -p "$BACKUP_DIR"


backup_dir() {
    local SRC="$1"
    local DST="$2"

    [[ -d "$SRC" ]] || return 0

    mkdir -p "$(dirname "$DST")"

    rsync -a --delete "$SRC/" "$DST/"

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


echo "=========================================="
echo " Backup del entorno"
echo "=========================================="


# Servicios usuario
systemctl --user list-unit-files --state=enabled \
> "$BACKUP_DIR/systemd-user-services.txt" || true

ok "Lista de servicios de usuario guardada."


# Shell
backup_dir "$HOME/.config/fish" \
"$BACKUP_DIR/fish"

backup_file "$HOME/.config/starship.toml" \
"$BACKUP_DIR/starship.toml"

###############################################################################
# Fuentes
###############################################################################

# Todas las fuentes instaladas por el usuario
backup_dir "$HOME/.local/share/fonts" \
"$BACKUP_DIR/fonts/user"


# Fuentes antiguas (compatibilidad)
backup_dir "$HOME/.fonts" \
"$BACKUP_DIR/fonts/legacy"


# Fuentes añadidas manualmente al sistema
# Ej: fuentes para DaVinci Resolve
backup_dir "/usr/share/fonts/custom" \
"$BACKUP_DIR/fonts/custom"

# Git
backup_dir "$HOME/.config/git" \
"$BACKUP_DIR/git"

backup_file "$HOME/.gitconfig" \
"$BACKUP_DIR/git/.gitconfig"


# VS Code
backup_dir "$HOME/.config/Code/User" \
"$BACKUP_DIR/vscode/User"

if command -v code >/dev/null; then

    mkdir -p "$BACKUP_DIR/vscode"

    code --list-extensions \
    > "$BACKUP_DIR/vscode/extensions.txt" || true

    ok "Extensiones de VS Code guardadas."

fi


# Navegador Floorp Flatpak
backup_dir "$HOME/.var/app/one.ablaze.floorp" \
"$BACKUP_DIR/browser/floorp"


# Flatpaks con configuración
backup_dir "$HOME/.var/app/com.usebottles.bottles" \
"$BACKUP_DIR/flatpak/bottles"

backup_dir "$HOME/.var/app/org.localsend.localsend_app" \
"$BACKUP_DIR/flatpak/localsend"


# Syncthing
backup_dir "$HOME/.config/syncthing" \
"$BACKUP_DIR/syncthing"


# SSH
backup_dir "$HOME/.ssh" \
"$BACKUP_DIR/ssh"


# Konsole
backup_dir "$HOME/.config/konsole" \
"$BACKUP_DIR/konsole"


###############################################################################
# DaVinci Resolve
###############################################################################

# Fusion Scripts externos
backup_dir "/opt/resolve/Fusion/Scripts" \
"$BACKUP_DIR/davinci/FusionScripts"


# Configuración DaVinci completa
mkdir -p "$BACKUP_DIR/davinci/database"

if [[ -d "$HOME/.local/share/DaVinciResolve" ]]; then

    rsync -a --delete \
    --exclude="logs" \
    --exclude=".cache" \
    --exclude=".ui.cache.db" \
    "$HOME/.local/share/DaVinciResolve/" \
    "$BACKUP_DIR/davinci/database/"

    ok "DaVinci Resolve respaldado."

fi


# Config adicional
backup_dir "$HOME/.config/DaVinciResolve" \
"$BACKUP_DIR/davinci/config"



###############################################################################
# KDE Plasma
###############################################################################

backup_file "$HOME/.config/kdeglobals" \
"$BACKUP_DIR/kde/kdeglobals"

backup_file "$HOME/.config/kwinrc" \
"$BACKUP_DIR/kde/kwinrc"

backup_file "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
"$BACKUP_DIR/kde/plasma-org.kde.plasma.desktop-appletsrc"

backup_dir "$HOME/.local/share/plasma" \
"$BACKUP_DIR/kde/plasma"

backup_dir "$HOME/.local/share/kxmlgui5" \
"$BACKUP_DIR/kde/kxmlgui5"

backup_file "$HOME/.config/kglobalshortcutsrc" \
"$BACKUP_DIR/kde/kglobalshortcutsrc"

backup_file "$HOME/.config/dolphinrc" \
"$BACKUP_DIR/kde/dolphinrc"

backup_file "$HOME/.config/kscreenlockerrc" \
"$BACKUP_DIR/kde/kscreenlockerrc"

backup_dir "$HOME/.local/share/kscreen" \
"$BACKUP_DIR/kde/kscreen"



###############################################################################
# Paquetes
###############################################################################

pacman -Qqm \
> "$BACKUP_DIR/aur-packages.txt" || true

ok "Lista de paquetes AUR guardada."


pacman -Qqe \
> "$BACKUP_DIR/packages.txt" || true

ok "Lista de paquetes guardada."


flatpak list --app --columns=application,origin \
> "$BACKUP_DIR/flatpaks.txt" || true

ok "Lista de Flatpaks guardada."



echo
echo "=========================================="
echo " Backup finalizado"
echo "=========================================="

find "$BACKUP_DIR" -maxdepth 2 | sort