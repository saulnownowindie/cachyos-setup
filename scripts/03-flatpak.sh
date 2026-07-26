#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 03
# Flatpak + Flathub
###############################################################################

info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

ok() {
    echo -e "\033[1;32m[ OK ]\033[0m $1"
}

warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

sudo -v

###############################################################################
# Dependencias
###############################################################################

info "Verificando Flatpak..."

sudo pacman -S --needed --noconfirm \
    flatpak \
    xdg-desktop-portal \
    xdg-desktop-portal-kde

###############################################################################
# Flathub
###############################################################################

if ! flatpak remote-list | grep -q "^flathub"; then
    info "Agregando repositorio Flathub..."

    sudo flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo
else
    ok "Flathub ya configurado"
fi

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

install_flatpak() {

    local app="$1"

    if flatpak info "$app" >/dev/null 2>&1; then
        ok "$app ya instalado"
    else
        info "Instalando $app..."
        flatpak install -y flathub "$app"
    fi
}

info "Instalando aplicaciones..."

for app in "${APPS[@]}"; do
    install_flatpak "$app"
done

###############################################################################
# Permisos
###############################################################################

info "Configurando permisos de Floorp..."

flatpak override --user \
    --filesystem=home \
    --filesystem=xdg-download \
    --filesystem=xdg-documents \
    --filesystem=xdg-pictures \
    --filesystem=xdg-videos \
    --filesystem=/run/media \
    one.ablaze.floorp || true

info "Configurando permisos de LocalSend..."

flatpak override --user \
    --filesystem=home \
    org.localsend.localsend_app || true

###############################################################################
# Actualización
###############################################################################

info "Actualizando Flatpaks..."

flatpak update -y

###############################################################################
# Resumen
###############################################################################

echo
echo "======================================"
echo " Flatpak configurado"
echo "======================================"
echo
echo "Instalados:"
echo " - Floorp"
echo " - Flatseal"
echo " - Warehouse"
echo " - Bottles"
echo " - LocalSend"
echo " - Obsidian"
echo
echo "Reinicia la sesión para asegurar el funcionamiento de los portales KDE."
