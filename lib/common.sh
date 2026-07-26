#!/usr/bin/env bash
# lib/common.sh

set -Eeuo pipefail

###############################################################################
# Directorios
###############################################################################

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$LIB_DIR")"
SCRIPT_DIR="$ROOT_DIR/scripts"

###############################################################################
# Colores
###############################################################################

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

: "${OK:=0}"
: "${WARN:=0}"
: "${FAIL:=0}"
###############################################################################
# Mensajes
###############################################################################

info() {
    echo -e "${BLUE}[INFO]${RESET} $*"
}

ok() {
    ((++OK))
    echo -e "${GREEN}[ OK ]${RESET} $*"
}

warn() {
    ((++WARN))
    echo -e "${YELLOW}[WARN]${RESET} $*"
}
fail() {
    echo -e "${RED}[FAIL]${RESET} $*"
    exit 1
}

separator() {
    echo
    printf '=%.0s' {1..70}
    echo
}

title() {
    separator
    echo " $1"
    separator
}

###############################################################################
# Comprobaciones
###############################################################################

require_cmd() {

    command -v "$1" >/dev/null 2>&1 || fail "Falta dependencia: $1"

}

require_sudo() {

    sudo -v || fail "No fue posible obtener privilegios sudo."

}

require_root() {

    [[ $EUID -eq 0 ]] || fail "Este script debe ejecutarse como root."

}
