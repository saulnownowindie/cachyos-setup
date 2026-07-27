#!/usr/bin/env bash
set -Eeuo pipefail


###############################################################################
# CachyOS Setup - Módulo 14
# Verificación final del sistema
###############################################################################


OK=0
WARN=0
FAIL=0


ok(){

    echo "[ OK ] $1"
    ((OK++))

}


warn(){

    echo "[WARN] $1"
    ((WARN++))

}


fail(){

    echo "[FAIL] $1"
    ((FAIL++))

}



check_cmd(){

    local CMD="$1"
    local NAME="$2"


    if command -v "$CMD" >/dev/null 2>&1; then

        local VERSION=""

        case "$CMD" in

            git)
                VERSION="$(git --version | awk '{print $3}')"
            ;;

            node)
                VERSION="$(node --version)"
            ;;

            pnpm)
                VERSION="$(pnpm --version)"
            ;;

            bun)
                VERSION="$(bun --version)"
            ;;

            code)
                VERSION="$(code --version | head -n1)"
            ;;

            ffmpeg)
                VERSION="$(ffmpeg -version | head -n1 | awk '{print $3}')"
            ;;

            syncthing)
                VERSION="$(syncthing --version | head -n1 | awk '{print $2}')"
            ;;

        esac


        ok "$NAME $VERSION"


    else

        warn "$NAME"

    fi

}



echo
echo "======================================================================"
echo " Verificación del sistema"
echo "======================================================================"



###############################################################################
# Aplicaciones
###############################################################################

check_cmd git "Git"
check_cmd gh "GitHub CLI"
check_cmd node "Node.js"
check_cmd pnpm "pnpm"
check_cmd bun "Bun"
check_cmd code "VS Code"
check_cmd ffmpeg "FFmpeg"
check_cmd syncthing "Syncthing"



###############################################################################
# AutoSubs
###############################################################################

if [[ -f /opt/resolve/Fusion/Scripts/Utility/AutoSubs.lua ]] &&
   [[ -x /usr/bin/autosubs-real || -x /usr/bin/autosubs ]]; then

    ok "AutoSubs"

else

    warn "AutoSubs"

fi



###############################################################################
# NVIDIA
###############################################################################

if command -v nvidia-smi >/dev/null &&
   nvidia-smi >/dev/null 2>&1; then

    ok "NVIDIA"

else

    fail "NVIDIA"

fi



###############################################################################
# DaVinci
###############################################################################

if [[ -x /opt/resolve/bin/resolve ]]; then

    ok "DaVinci Resolve"

else

    warn "DaVinci Resolve"

fi



###############################################################################
# Syncthing
###############################################################################

if sudo -u saul \
XDG_RUNTIME_DIR=/run/user/$(id -u saul) \
systemctl --user is-enabled syncthing.service >/dev/null 2>&1; then

    ok "Servicio Syncthing"

else

    warn "Servicio Syncthing"

fi



###############################################################################
# Discos
###############################################################################

echo
echo "Discos"
echo "--------------------------------"



DISCOS=(

"SSD500:/mnt/SSD500"

"HDDX201TB:/mnt/hddx201tb"

)



for ITEM in "${DISCOS[@]}"; do


    NAME="${ITEM%%:*}"
    PATH="${ITEM#*:}"


    if mountpoint -q "$PATH"; then

        ok "$NAME"

    else

        warn "$NAME"

    fi


done



###############################################################################
# Fuentes
###############################################################################

echo
echo "Fuentes"
echo "--------------------------------"


if fc-match Oswald >/dev/null 2>&1; then

    ok "Fuentes personalizadas"

else

    warn "Fuentes personalizadas"

fi



###############################################################################
# KDE
###############################################################################

if pgrep -u saul plasmashell >/dev/null; then

    ok "KDE Plasma"

else

    warn "KDE Plasma"

fi



###############################################################################
# Resultado
###############################################################################

echo
echo "================ RESUMEN ================"

echo "OK   : $OK"
echo "WARN : $WARN"
echo "FAIL : $FAIL"

echo "========================================="


[[ "$FAIL" -eq 0 ]]
