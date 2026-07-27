#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 03
# Flatpak + Flathub
###############################################################################

sudo -v

###############################################################################
# Dependencias
###############################################################################

info "Instalando Flatpak..."

sudo pacman -S --needed --noconfirm \
    flatpak \
    xdg-desktop-portal \
    xdg-desktop-portal-kde


###############################################################################
# Flathub
###############################################################################

info "Configurando Flathub..."

flatpak remote-add \
    --if-not-exists \
    --user \
    flathub \
    https://flathub.org/repo/flathub.flatpakrepo || true


sudo flatpak remote-add \
    --if-not-exists \
    flathub \
    https://flathub.org/repo/flathub.flatpakrepo || true


ok "Flathub configurado"


###############################################################################
# Aplicaciones
###############################################################################

APPS=(
    one.ablaze.floorp
    com.github.tchx84.Flatseal
    io.github.flattool.Warehouse
    com.usebottles.bottles
    org.localsend.localsend_app
    md.obsidian.Obsidian
)


for app in "${APPS[@]}"; do

    if flatpak --user info "$app" >/dev/null 2>&1; then

        ok "$app ya instalado"

    else

        info "Instalando $app..."

        flatpak --user install \
            -y \
            flathub \
            "$app" || warn "No se pudo instalar $app"

    fi

done


###############################################################################
# Permisos
###############################################################################

info "Configurando permisos..."


flatpak override --user \
    --filesystem=home \
    --filesystem=xdg-download \
    --filesystem=xdg-documents \
    --filesystem=xdg-pictures \
    --filesystem=xdg-videos \
    --filesystem=/run/media \
    one.ablaze.floorp || true


flatpak override --user \
    --filesystem=home \
    org.localsend.localsend_app || true


###############################################################################
# Actualización
###############################################################################

info "Actualizando Flatpaks..."

flatpak --user update -y || true


echo
echo "======================================"
echo " Flatpak configurado"
echo "======================================"
echo

ok "Módulo 03 completado."