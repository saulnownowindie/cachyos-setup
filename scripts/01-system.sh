#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 01
# Sistema Base
###############################################################################

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

info(){ echo -e "${BLUE}[INFO]${RESET} $1"; }
ok(){ echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${RESET} $1"; }
fail(){ echo -e "${RED}[FAIL]${RESET} $1"; exit 1; }

[[ -f /etc/arch-release ]] || fail "Este script requiere Arch Linux / CachyOS."

info "Solicitando permisos..."
sudo -v

( while true; do sudo -n true; sleep 30; done ) &
KEEP=$!
trap "kill $KEEP" EXIT

ping -c1 archlinux.org >/dev/null 2>&1 || warn "No se pudo verificar Internet."

info "Activando NTP..."
sudo timedatectl set-ntp true

if command -v rate-mirrors >/dev/null 2>&1; then
    info "Actualizando mirrors..."
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist >/dev/null
fi

info "Actualizando sistema..."
sudo pacman -Syu --noconfirm

info "Instalando herramientas base..."
sudo pacman -S --needed --noconfirm \
base-devel git curl wget rsync openssh zip unzip p7zip tar \
bash-completion nano vim less tree htop btop fastfetch \
jq yq ripgrep fd fzf which inetutils dnsutils traceroute \
bind net-tools lsof dos2unix eza bat flatpak xdg-utils xdg-user-dirs

info "Habilitando SSH..."
sudo systemctl enable sshd

info "Creando carpetas..."
mkdir -p \
"$HOME/Proyectos" \
"$HOME/Scripts" \
"$HOME/Backups" \
"$HOME/ISOs" \
"$HOME/Temp" \
"$HOME/.local/bin"

git config --global init.defaultBranch main

if ! grep -q '.local/bin' "$HOME/.bashrc"; then
cat >> "$HOME/.bashrc" <<'EOF'

# CachyOS Setup
export PATH="$HOME/.local/bin:$PATH"
EOF
fi

ok "Sistema base preparado."

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

echo
echo "======================================"
echo " MÓDULO 01 COMPLETADO"
echo "======================================"
