#!/usr/bin/env bash
set -Eeuo pipefail


BACKUP="${1:-}"


OK=0
WARN=0
FAIL=0


ok(){

echo "[ OK ] $1"
OK=$((OK+1))

}


warn(){

echo "[WARN] $1"
WARN=$((WARN+1))

}


fail(){

echo "[FAIL] $1"
FAIL=$((FAIL+1))

}



if [[ -z "$BACKUP" ]]; then

echo "Uso:"
echo "$0 /ruta/backups"

exit 1

fi



echo
echo "=========================================="
echo " Verificando backup CachyOS"
echo " Ruta: $BACKUP"
echo "=========================================="



###############################################################################
# Usuario
###############################################################################

echo
echo "Usuario"
echo "--------------------------------"



if [[ -d "$BACKUP/fish" ]]; then
    ok "Fish backup encontrado."
else
    warn "Fish backup no encontrado."
fi



[[ -f "$BACKUP/git/.gitconfig" ]] \
&& ok "Git config" \
|| warn "Git config"



[[ -d "$BACKUP/vscode/User" ]] \
&& ok "VS Code" \
|| warn "VS Code"



###############################################################################
# Fuentes
###############################################################################

echo
echo "Fuentes"
echo "--------------------------------"



[[ -d "$BACKUP/fonts/user" ]] \
&& ok "Fuentes usuario" \
|| warn "Fuentes usuario"



[[ -d "$BACKUP/fonts/custom" ]] \
&& ok "Fuentes sistema" \
|| warn "Fuentes sistema"



###############################################################################
# Aplicaciones
###############################################################################

echo
echo "Aplicaciones"
echo "--------------------------------"



[[ -d "$BACKUP/browser/floorp" ]] \
&& ok "Floorp" \
|| warn "Floorp"



[[ -d "$BACKUP/obs" ]] \
&& ok "OBS" \
|| warn "Sin configuración OBS"



[[ -d "$BACKUP/syncthing" ]] \
&& ok "Syncthing" \
|| warn "Sin configuración Syncthing"



###############################################################################
# DaVinci
###############################################################################

echo
echo "DaVinci Resolve"
echo "--------------------------------"



[[ -d "$BACKUP/davinci/database" ]] \
&& ok "Base DaVinci" \
|| warn "Base DaVinci"



[[ -d "$BACKUP/davinci/FusionScripts" ]] \
&& ok "Fusion Scripts" \
|| warn "Fusion Scripts"



###############################################################################
# KDE
###############################################################################

echo
echo "KDE Plasma"
echo "--------------------------------"



[[ -f "$BACKUP/kde/kdeglobals" ]] \
&& ok "KDE globals" \
|| warn "KDE globals"



[[ -f "$BACKUP/kde/kwinrc" ]] \
&& ok "KWin" \
|| warn "KWin"



[[ -f "$BACKUP/kde/kglobalshortcutsrc" ]] \
&& ok "Atajos KDE" \
|| warn "Atajos KDE"



###############################################################################
# Paquetes
###############################################################################

echo
echo "Paquetes"
echo "--------------------------------"



[[ -f "$BACKUP/packages.txt" ]] \
&& ok "Pacman" \
|| fail "Pacman"



[[ -f "$BACKUP/aur-packages.txt" ]] \
&& ok "AUR" \
|| warn "AUR"



[[ -f "$BACKUP/flatpaks.txt" ]] \
&& ok "Flatpaks" \
|| fail "Flatpaks"



echo
echo "=========================================="


if [[ "$FAIL" -eq 0 ]]; then

echo " BACKUP COMPLETO"

else

echo " BACKUP INCOMPLETO"

fi


echo
echo "OK   : $OK"
echo "WARN : $WARN"
echo "FAIL : $FAIL"



[[ "$FAIL" -eq 0 ]]
