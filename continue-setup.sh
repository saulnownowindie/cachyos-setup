#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/state.sh"

###############################################################################
# No hay instalación pendiente
###############################################################################

has_state || exit 0

load_state

[[ -n "${NEXT_SCRIPT:-}" ]] || exit 0

SCRIPT="$ROOT_DIR/scripts/$NEXT_SCRIPT"

[[ -f "$SCRIPT" ]] || {

    fail "No existe el módulo $NEXT_SCRIPT"

}

###############################################################################
# Abrir Konsole
###############################################################################

if command -v konsole >/dev/null 2>&1; then

    konsole \
        --hold \
        -e bash -c "
            cd \"$ROOT_DIR\"
            ./install.sh --resume
        " &

else

    xterm -hold -e "
        cd \"$ROOT_DIR\"
        ./install.sh --resume
    " &

fi

exit 0
