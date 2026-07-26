#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

check_cmd() {
    local cmd="$1"
    local nombre="$2"
    local version=""

if ! command -v "$cmd" >/dev/null 2>&1; then
    check_fail "$nombre"
    return
fi

    case "$cmd" in
        git)        version="v$(git --version | awk '{print $3}')" ;;
        gh)         version="v$(gh --version | awk 'NR==1{print $3}')" ;;
        node)       version="$(node --version)" ;;
        pnpm)       version="v$(pnpm --version)" ;;
        bun)        version="v$(bun --version)" ;;
        code)       version="v$(code --version | head -n1)" ;;
        ffmpeg)     version="$(ffmpeg -version | awk 'NR==1{print $3}')" ;;
        syncthing)  version="$(syncthing --version | awk 'NR==1{print $2}')" ;;
        *)
                    version=""
    ;;
    esac

    ok "$nombre $version"
}

title "Verificación del sistema"

check_cmd git "Git"
check_cmd gh "GitHub CLI"
check_cmd node "Node.js"
check_cmd pnpm "pnpm"
check_cmd bun "Bun"
check_cmd code "VS Code"
check_cmd ffmpeg "FFmpeg"
check_cmd syncthing "Syncthing"

if command -v autosubs >/dev/null 2>&1 \
   && [[ -x /usr/bin/autosubs-real ]] \
   && [[ -f /opt/resolve/Fusion/Scripts/Utility/AutoSubs.lua ]]; then

    ok "AutoSubs"

else

    warn "AutoSubs"

fi

if nvidia-smi >/dev/null 2>&1; then
    ok "NVIDIA"
else
    check_fail "NVIDIA"
fi

if command -v resolve >/dev/null 2>&1 \
   || [[ -x /opt/resolve/bin/resolve ]]; then

    ok "DaVinci Resolve"

else

    warn "DaVinci Resolve no instalado"

fi

if systemctl --user is-enabled syncthing >/dev/null 2>&1 &&
   systemctl --user is-active syncthing >/dev/null 2>&1; then

    ok "Servicio Syncthing"

else

    warn "Servicio Syncthing"

fi

if findmnt -rn -S /dev/sdb1 >/dev/null 2>&1 &&
   findmnt -rn -S /dev/sdc2 >/dev/null 2>&1; then

    ok "Discos de datos"

else

    warn "Discos de datos"

fi

[[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]] && ok "KDE Plasma" || warn "No estás en KDE Plasma"

echo
echo "================ RESUMEN ================"
echo "OK   : $OK"
echo "WARN : $WARN"
echo "FAIL : $FAIL"
echo "========================================="

((FAIL==0))
