#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 05
# Entorno JavaScript
###############################################################################

info(){ echo -e "\033[1;34m[INFO]\033[0m $1"; }
ok(){ echo -e "\033[1;32m[ OK ]\033[0m $1"; }
warn(){ echo -e "\033[1;33m[WARN]\033[0m $1"; }
error(){ echo -e "\033[1;31m[FAIL]\033[0m $1"; exit 1; }

sudo -v

###############################################################################
# Instalar entorno JavaScript
###############################################################################

info "Instalando entorno JavaScript..."

sudo pacman -S --needed --noconfirm \
    nodejs npm pnpm bun \
    git github-cli \
    python python-pip \
    docker docker-compose \
    postgresql-libs

###############################################################################
# Limpiar configuración antigua de npm
###############################################################################

if [[ -f "$HOME/.npmrc" ]] && grep -q '^prefix=' "$HOME/.npmrc"; then
    info "Eliminando configuración antigua de npm..."
    npm config delete prefix >/dev/null 2>&1 || true
    rm -f "$HOME/.npmrc"
fi

###############################################################################
# Configurar Docker
###############################################################################

info "Configurando Docker..."

sudo systemctl enable docker.service >/dev/null

if ! systemctl is-active --quiet docker.service; then
    sudo systemctl start docker.service
fi

###############################################################################
# Grupo docker
###############################################################################

USER_ADDED=false

if ! getent group docker | grep -qw "$USER"; then
    sudo usermod -aG docker "$USER"
    USER_ADDED=true
fi

###############################################################################
# Resumen
###############################################################################

echo
echo "========================================="
echo " Entorno JavaScript listo"
echo "========================================="
echo

printf "%-12s %s\n" "Node.js" "$(node -v 2>/dev/null || echo 'No instalado')"
printf "%-12s %s\n" "npm" "$(npm -v 2>/dev/null || echo 'No instalado')"
printf "%-12s %s\n" "pnpm" "$(pnpm -v 2>/dev/null || echo 'No instalado')"
printf "%-12s %s\n" "Bun" "$(bun --version 2>/dev/null || echo 'No instalado')"
printf "%-12s %s\n" "Docker" "$(docker --version 2>/dev/null | cut -d',' -f1 || echo 'No instalado')"

echo

if id -nG | grep -qw docker; then

    ok "El grupo docker ya está activo."

else

    if $USER_ADDED; then
        warn "El usuario fue agregado al grupo docker."
    else
        warn "El usuario pertenece al grupo docker, pero la sesión actual todavía no lo refleja."
    fi

    if loginctl session-status 2>/dev/null | grep -qi autologin; then
        warn "Se detectó inicio de sesión automático (autologin)."
    fi

    warn "Se recomienda reiniciar el equipo una vez antes de utilizar Docker."
    warn "Si no desea reiniciar ahora, puede activar el grupo en esta terminal con:"
    echo
    echo "    newgrp docker"
    echo
fi

ok "Módulo 05 completado."

warn "No se utiliza Corepack."
warn "No se ejecuta pnpm setup (bug detectado en pnpm 11.x de Arch/CachyOS)."
warn "No se instalan paquetes npm globales."
