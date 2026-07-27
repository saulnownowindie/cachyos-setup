#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 12
# Development Workspace
###############################################################################

WORKSPACE="$HOME/Proyectos"

REPOS=(
    "saulnownowindie/indie-now"
    "saulnownowindie/indie-now-api"
    "saulnownowindie/cachyos-setup"
    "saulnownowindie/opensuse-setup"
)

require_sudo

for cmd in git node; do
    command -v "$cmd" >/dev/null || fail "Falta dependencia: $cmd"
done

mkdir -p "$WORKSPACE"

ORIGINAL_DIR="$PWD"

TOTAL=0
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

for REPO in "${REPOS[@]}"; do

  ((++TOTAL))

    NAME="${REPO##*/}"
    DEST="$WORKSPACE/$NAME"

    echo
    info "Procesando $NAME"

    ###########################################################
    # Clonar / actualizar
    ###########################################################

    if [[ -d "$DEST/.git" ]]; then

        if ! git -C "$DEST" pull --ff-only; then
            warn "No se pudo actualizar $NAME"
            ((++FAIL_COUNT))
            continue
        fi

    else

        if ! git clone "https://github.com/$REPO.git" "$DEST"; then
            warn "No se pudo clonar $NAME"
            ((++FAIL_COUNT))
            continue
        fi

    fi

    ###########################################################
    # Dependencias JS
    ###########################################################

    if [[ ! -f "$DEST/package.json" ]]; then
        ok "$NAME no tiene package.json"
       ((++OK_COUNT))
        continue
    fi

    cd "$DEST"

    if command -v pnpm >/dev/null; then

        set +e
        OUTPUT="$(pnpm install 2>&1)"
        STATUS=$?
        set -e

        echo "$OUTPUT"

        if (( STATUS == 0 )); then

            ok "Dependencias instaladas."
           ((++OK_COUNT))
            continue

        fi

        #######################################################
        # pnpm approve-builds
        #######################################################

        if grep -q "ERR_PNPM_IGNORED_BUILDS" <<<"$OUTPUT"; then

            warn "pnpm requiere approve-builds."

            cat <<EOF

Ejecuta cuando quieras:

cd "$DEST"
pnpm approve-builds
pnpm install

EOF

            ((++WARN_COUNT))
            continue

        fi

        #######################################################
        # Error real
        #######################################################

        warn "pnpm install falló en $NAME."
        ((++FAIL_COUNT))

    elif command -v npm >/dev/null; then

        if npm install; then
            ok "Dependencias instaladas."
           ((++OK_COUNT))
        else
            warn "npm install falló."
            ((++FAIL_COUNT))
        fi

    else

        warn "No se encontró pnpm ni npm."
        ((++FAIL_COUNT))

    fi

done

cd "$ORIGINAL_DIR"

echo
echo "=========================================="
echo " Workspace listo"
echo "=========================================="
echo
echo "Repositorios : $TOTAL"
echo "Correctos    : $OK_COUNT"
echo "Advertencias : $WARN_COUNT"
echo "Errores      : $FAIL_COUNT"

###############################################################
# Resultado del módulo
###############################################################

if (( FAIL_COUNT > 0 )); then
    fail "Hubo errores reales durante la configuración."
fi

ok "Workspace configurado correctamente."