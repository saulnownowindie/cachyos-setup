#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/reboot.sh"

TOTAL=$(find "$ROOT_DIR/scripts" -maxdepth 1 -name '[0-9][0-9]-*.sh' | wc -l)

FAILED=()

FIRST_SCRIPT=""

###############################################################################
# Resume
###############################################################################

if [[ "${1:-}" == "--resume" ]]; then

    load_state || fail "No existe una instalación pendiente."

    FIRST_SCRIPT="$NEXT_SCRIPT"

else

    if has_state; then

        load_state

        echo
        warn "Se encontró una instalación pendiente."
        echo
        echo "Continuar desde:"
        echo "    $NEXT_SCRIPT"
        echo

        read -rp "[C] Continuar / [R] Reiniciar: " ans

        ans=${ans:-C}

        case "$ans" in

            c|C)

                FIRST_SCRIPT="$NEXT_SCRIPT"
                ;;

            r|R)

                clear_state
                remove_autostart

                FIRST_SCRIPT=$(basename "$(find "$ROOT_DIR/scripts" -name '[0-9][0-9]-*.sh' | sort | head -n1)")
                ;;

            *)

                exit 0
                ;;

        esac

    else

        FIRST_SCRIPT=$(basename "$(find "$ROOT_DIR/scripts" -name '[0-9][0-9]-*.sh' | sort | head -n1)")

    fi

fi

###############################################################################
# Instalación
###############################################################################

echo
title "CachyOS Setup"

START=false
INDEX=0


for SCRIPT in "$ROOT_DIR"/scripts/[0-9][0-9]-*.sh; do

    FILE=$(basename "$SCRIPT")
    INDEX=$((INDEX + 1))

    if [[ "$START" == false ]]; then

        if [[ "$FILE" == "$FIRST_SCRIPT" ]]; then
            START=true
        else
            continue
        fi

    fi

    separator

    echo "[$INDEX/$TOTAL] $FILE"

    separator

    if bash "$SCRIPT"; then

        ok "$FILE finalizado."

    else

        FAILED+=("$FILE")

        warn "$FILE terminó con errores."

    fi

done

###############################################################################
# Final
###############################################################################

if [[ ${#FAILED[@]} -eq 0 ]]; then

    clear_state

    remove_autostart

    echo
    title "INSTALACIÓN COMPLETADA"

    ok "Todos los módulos finalizaron correctamente."

else

    echo

    title "INSTALACIÓN INCOMPLETA"

    printf ' - %s\n' "${FAILED[@]}"

fi
