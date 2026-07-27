#!/usr/bin/env bash
set -Eeuo pipefail


BACKUP_ROOT="${1:-/mnt/CACHY-BACKUP/backups}"


ERRORS=0


ok(){
    echo "[ OK ] $1"
}


warn(){
    echo "[WARN] $1"
}


fail(){
    echo "[FAIL] $1"
    ERRORS=$((ERRORS+1))
}



check_dir(){

    if [[ -d "$1" ]]; then
        ok "$2"
    else
        fail "$2"
    fi

}



check_file(){

    if [[ -f "$1" ]]; then
        ok "$2"
    else
        fail "$2"
    fi

}



echo
echo "=========================================="
echo " Verificando backup CachyOS"
echo " Ruta: $BACKUP_ROOT"
echo "=========================================="
echo



###############################################################################
# Usuario
###############################################################################

echo "Usuario"
echo "--------------------------------"


check_dir \
"$BACKUP_ROOT/fish" \
"Fish"



if [[ -f "$BACKUP_ROOT/starship.toml" ]]; then

    ok "Starship"

else

    warn "Starship no configurado"

fi



check_file \
"$BACKUP_ROOT/git/.gitconfig" \
"Git config"



check_dir \
"$BACKUP_ROOT/vscode/User" \
"VS Code"



###############################################################################
# Fuentes
###############################################################################

echo
echo "Fuentes"
echo "--------------------------------"


check_dir \
"$BACKUP_ROOT/fonts/user" \
"Fuentes usuario"



check_dir \
"$BACKUP_ROOT/fonts/custom" \
"Fuentes sistema"



if [[ -d "$BACKUP_ROOT/fonts/legacy" ]]; then

    ok "Fuentes legacy"

else

    warn "Sin fuentes legacy"

fi



###############################################################################
# Aplicaciones
###############################################################################

echo
echo "Aplicaciones"
echo "--------------------------------"


check_dir \
"$BACKUP_ROOT/browser/floorp" \
"Floorp"



if [[ -d "$BACKUP_ROOT/obs" ]]; then

    ok "OBS"

else

    warn "Sin configuración OBS"

fi



if [[ -d "$BACKUP_ROOT/syncthing" ]]; then

    ok "Syncthing"

else

    warn "Sin configuración Syncthing"

fi



###############################################################################
# DaVinci
###############################################################################

echo
echo "DaVinci Resolve"
echo "--------------------------------"


check_dir \
"$BACKUP_ROOT/davinci/database" \
"Base DaVinci"



check_dir \
"$BACKUP_ROOT/davinci/FusionScripts" \
"Fusion Scripts"



if [[ -d "$BACKUP_ROOT/davinci/config" ]]; then

    ok "Configuración DaVinci"

else

    warn "Sin configuración externa DaVinci"

fi



###############################################################################
# KDE
###############################################################################

echo
echo "KDE Plasma"
echo "--------------------------------"


check_file \
"$BACKUP_ROOT/kde/kdeglobals" \
"KDE globals"



check_file \
"$BACKUP_ROOT/kde/kwinrc" \
"KWin"



check_file \
"$BACKUP_ROOT/kde/kglobalshortcutsrc" \
"Atajos KDE"



###############################################################################
# Paquetes
###############################################################################

echo
echo "Paquetes"
echo "--------------------------------"


check_file \
"$BACKUP_ROOT/packages.txt" \
"Pacman"



check_file \
"$BACKUP_ROOT/aur-packages.txt" \
"AUR"



check_file \
"$BACKUP_ROOT/flatpaks.txt" \
"Flatpaks"



###############################################################################
# Resultado
###############################################################################

echo
echo "=========================================="


if [[ $ERRORS -eq 0 ]]; then

    echo " BACKUP COMPLETO"

else

    echo " BACKUP INCOMPLETO"
    echo "Faltan: $ERRORS elementos"

    exit 1

fi