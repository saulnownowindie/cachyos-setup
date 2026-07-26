#!/usr/bin/env bash
# lib/reboot.sh

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/state.sh"

AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/cachyos-setup.desktop"

###############################################################################
# Crear Autostart
###############################################################################

create_autostart() {

    mkdir -p "$AUTOSTART_DIR"

    cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=CachyOS Setup Resume
Exec=$ROOT_DIR/continue-setup.sh
Terminal=false
X-KDE-AutostartScript=false
EOF

}

###############################################################################
# Eliminar Autostart
###############################################################################

remove_autostart() {

    rm -f "$AUTOSTART_FILE"

}

###############################################################################
# Obtener siguiente módulo
###############################################################################

next_module() {

    local current="$1"

    local found=false

    for f in "$SCRIPT_DIR"/[0-9][0-9]-*.sh; do

        file=$(basename "$f")

        if $found; then
            echo "$file"
            return 0
        fi

        [[ "$file" == "$current" ]] && found=true

    done

    return 1

}

###############################################################################
# Solicitar reinicio
###############################################################################

request_reboot() {

    local current="$1"

    local next

    next=$(next_module "$current") || {

        warn "No existe un módulo posterior."

        return

    }

    save_state "$next"

    create_autostart

    echo
    warn "Es necesario reiniciar el equipo."
    echo
    echo "La instalación continuará automáticamente desde:"
    echo
    echo "    $next"
    echo

    read -rp "¿Desea reiniciar ahora? [S/n]: " ans

    ans=${ans:-S}

    case "$ans" in

        s|S|y|Y)

            sudo systemctl reboot
            exit 0
            ;;

        *)

            echo
            warn "La instalación quedó pausada."
            echo
            echo "Puede continuar cuando desee ejecutando:"
            echo
            echo "    ./install.sh"
            echo
            exit 0
            ;;

    esac

}