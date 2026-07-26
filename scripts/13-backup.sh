#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

# CachyOS Setup - Módulo 13
# Backup del entorno

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT/backups"

mkdir -p "$BACKUP_DIR"

backup_dir() {
    local SRC="$1" DST="$2"
    [[ -d "$SRC" ]] || return 0
    mkdir -p "$(dirname "$DST")"
    rsync -a --delete "$SRC/" "$DST/"
    ok "Respaldado: $SRC"
}



backup_file() {
    local SRC="$1" DST="$2"
    [[ -f "$SRC" ]] || return 0
    mkdir -p "$(dirname "$DST")"
    cp -f "$SRC" "$DST"
    ok "Respaldado: $SRC"
}

echo "=========================================="
echo " Backup del entorno"
echo "=========================================="

backup_dir "$HOME/.config/fish" "$BACKUP_DIR/fish"
backup_dir "$HOME/.config/git" "$BACKUP_DIR/git"
backup_dir "$HOME/.config/Code/User" "$BACKUP_DIR/vscode/User"
backup_dir "$HOME/.config/obs-studio" "$BACKUP_DIR/obs"
backup_dir "$HOME/.var/app/one.ablaze.floorp" "$BACKUP_DIR/browser/floorp"

backup_dir "$HOME/.var/app/com.usebottles.bottles" "$BACKUP_DIR/flatpak/bottles"
backup_dir "$HOME/.var/app/org.localsend.localsend_app" "$BACKUP_DIR/flatpak/localsend"
backup_dir "$HOME/.config/syncthing" "$BACKUP_DIR/syncthing"
backup_dir "$HOME/.ssh" "$BACKUP_DIR/ssh"

backup_dir "$HOME/.local/share/DaVinciResolve" "$BACKUP_DIR/davinci/DaVinciResolve"
backup_dir "/opt/resolve/Fusion/Scripts" "$BACKUP_DIR/davinci/FusionScripts"

backup_file "$HOME/.gitconfig" "$BACKUP_DIR/git/.gitconfig"

if command -v code >/dev/null && code --help 2>/dev/null | grep -q export-profile; then
    mkdir -p "$BACKUP_DIR/vscode"
    code --export-profile "$BACKUP_DIR/vscode/vsmain.code-profile" >/dev/null 2>&1 || true
fi

echo
echo "=========================================="
echo " Backup finalizado"
echo "=========================================="

find "$BACKUP_DIR" -maxdepth 2 | sort
