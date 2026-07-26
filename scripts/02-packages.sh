#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 02
# Paquetes principales
###############################################################################

info(){ echo -e "\033[1;34m[INFO]\033[0m $1"; }
ok(){ echo -e "\033[1;32m[ OK ]\033[0m $1"; }

sudo -v

PACKAGES=(
firefox
code
github-cli
git-lfs
nodejs
npm
pnpm
bun
ffmpeg
mediainfo
imagemagick
yt-dlp
obs-studio
gimp
inkscape
vlc
mpv
spotify-launcher
steam
heroic-games-launcher
discord
telegram-desktop
filezilla
syncthing
qbittorrent
flatpak
)

info "Instalando paquetes oficiales..."

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        ok "$pkg ya instalado"
    else
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done

# Servicios
if systemctl --user list-unit-files | grep -q '^syncthing.service'; then
    systemctl --user enable syncthing.service >/dev/null 2>&1 || true
fi

# Git LFS
if command -v git-lfs >/dev/null 2>&1; then
    git lfs install
fi

# Corepack para pnpm
# Corepack (si está disponible)
if command -v corepack >/dev/null 2>&1; then
    info "Activando Corepack..."
    corepack enable
else
    info "Corepack no disponible. Se omite."
fi

# Bun
if ! command -v bun >/dev/null 2>&1; then
    info "Instalando Bun desde el instalador oficial..."
    curl -fsSL https://bun.sh/install | bash
fi

echo
echo "======================================"
echo " Software instalado"
echo "======================================"
echo
echo "Incluye:"
echo "- VS Code / Code OSS (según repositorio)"
echo "- GitHub CLI"
echo "- Node.js + npm + pnpm + Bun"
echo "- FFmpeg, MediaInfo, ImageMagick"
echo "- OBS Studio"
echo "- Kdenlive"
echo "- GIMP"
echo "- Inkscape"
echo "- VLC y MPV"
echo "- Spotify"
echo "- Steam"
echo "- Heroic Games Launcher"
echo "- Discord"
echo "- Telegram"
echo "- Syncthing"
echo
echo "REAPER no se instala automáticamente."
echo "Se agregará en un módulo multimedia opcional para descargar siempre la versión más reciente desde Cockos."
