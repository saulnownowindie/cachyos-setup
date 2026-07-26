#!/usr/bin/env bash
# lib/state.sh

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

###############################################################################
# Directorios
###############################################################################

STATE_DIR="$HOME/.local/state/cachyos-setup"
STATE_FILE="$STATE_DIR/state"

###############################################################################
# Inicializar
###############################################################################

init_state() {

    mkdir -p "$STATE_DIR"

}

###############################################################################
# Guardar siguiente módulo
###############################################################################

save_state() {

    local next_script="$1"

    init_state

    cat > "$STATE_FILE" <<EOF
NEXT_SCRIPT="$next_script"
UPDATED="$(date '+%Y-%m-%d %H:%M:%S')"
EOF

}

###############################################################################
# Leer estado
###############################################################################

load_state() {

    [[ -f "$STATE_FILE" ]] || return 1

    # shellcheck disable=SC1090
    source "$STATE_FILE"

}

###############################################################################
# Existe estado
###############################################################################

has_state() {

    [[ -f "$STATE_FILE" ]]

}

###############################################################################
# Obtener siguiente script
###############################################################################

next_script() {

    load_state || return 1

    printf "%s\n" "$NEXT_SCRIPT"

}

###############################################################################
# Limpiar estado
###############################################################################

clear_state() {

    rm -f "$STATE_FILE"

}

###############################################################################
# Mostrar estado
###############################################################################

show_state() {

    if ! has_state; then
        info "No existe ninguna instalación pendiente."
        return
    fi

    load_state

    echo
    echo "Estado actual"
    echo "-------------"
    echo "Siguiente módulo : $NEXT_SCRIPT"
    echo "Última actualización : $UPDATED"
    echo

}
