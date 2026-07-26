#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUPS="$ROOT/backups"

copydir(){
SRC="$1"; DST="$2"
[ -d "$SRC" ] || return 0
mkdir -p "$DST"
rsync -a "$SRC"/ "$DST"/
echo "Restaurado: $DST"
}

copyfile(){
SRC="$1"; DST="$2"
[ -f "$SRC" ] || return 0
mkdir -p "$(dirname "$DST")"
cp -f "$SRC" "$DST"
echo "Restaurado: $DST"
}

copydir "$BACKUPS/fish" "$HOME/.config/fish"
copydir "$BACKUPS/vscode/User" "$HOME/.config/Code/User"
copydir "$BACKUPS/syncthing" "$HOME/.config/syncthing"
copydir "$BACKUPS/obs" "$HOME/.config/obs-studio"
copydir "$BACKUPS/fonts" "$HOME/.local/share/fonts"
copydir "$BACKUPS/kde/config" "$HOME/.config"
copydir "$BACKUPS/kde/plasma" "$HOME/.local/share/plasma"
copydir "$BACKUPS/davinci/Config" "$HOME/.local/share/DaVinciResolve"
copyfile "$BACKUPS/git/.gitconfig" "$HOME/.gitconfig"

if command -v fc-cache >/dev/null; then
 fc-cache -fv || true
fi

echo "Restauración finalizada."
