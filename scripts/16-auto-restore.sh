#!/usr/bin/env bash
set -Eeuo pipefail

###############################################################################
# CachyOS Setup - Módulo 16
# Restauración automática completa
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

###############################################################################
# Funciones
###############################################################################

ok(){
    echo -e "\033[1;32m[ OK ]\033[0m $1"
}

warn(){
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

fail(){
    echo -e "\033[1;31m[FAIL]\033[0m $1"
    exit 1
}


###############################################################################
# Buscar backup
###############################################################################

echo
echo "=========================================="
echo " Auto Restore CachyOS"
echo "=========================================="
echo

echo "Buscando backup..."

FOUND_BACKUP=""
TEMP_MOUNT="/mnt/cachy-search"

sudo mkdir -p "$TEMP_MOUNT"


PARTITIONS=$(lsblk -lnpo NAME,TYPE | awk '$2=="part"{print $1}')


for PART in $PARTITIONS; do

    echo "Probando $PART"

    SEARCH_ROOT=""

    CURRENT=$(findmnt -nr -o TARGET "$PART" || true)

    if [[ -n "$CURRENT" ]]; then

        SEARCH_ROOT="$CURRENT"

    else

        if sudo mount "$PART" "$TEMP_MOUNT" 2>/dev/null; then
            SEARCH_ROOT="$TEMP_MOUNT"
        else
            continue
        fi

    fi


    if [[ -d "$SEARCH_ROOT/backups-cachyos/backups" ]] &&
       [[ -d "$SEARCH_ROOT/backups-cachyos/cachyos-setup" ]]; then

        FOUND_BACKUP="$SEARCH_ROOT/backups-cachyos"
        break

    fi


    if [[ "$SEARCH_ROOT" == "$TEMP_MOUNT" ]]; then
        sudo umount "$TEMP_MOUNT" || true
    fi

done


[[ -z "$FOUND_BACKUP" ]] && fail "No se encontró backup"


BACKUP_ROOT="$FOUND_BACKUP/backups"
SETUP_ROOT="$FOUND_BACKUP/cachyos-setup"


ok "Backup encontrado:"
echo "$BACKUP_ROOT"


ok "Scripts encontrados:"
echo "$SETUP_ROOT"



###############################################################################
# Verificar backup
###############################################################################

echo
echo "Verificando backup..."

bash "$SETUP_ROOT/scripts/15-verify-backup.sh" "$BACKUP_ROOT"

ok "Backup válido"



###############################################################################
# Actualizar sistema
###############################################################################

echo
echo "Actualizando sistema..."

sudo pacman -Syu --noconfirm



###############################################################################
# Paquetes Pacman
###############################################################################

if [[ -f "$BACKUP_ROOT/packages.txt" ]]; then

echo
echo "Restaurando paquetes..."

mapfile -t PACKAGES < "$BACKUP_ROOT/packages.txt"

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" || true

ok "Paquetes restaurados"

fi



###############################################################################
# Instalar yay correctamente como usuario
###############################################################################

install_yay(){

    if command -v yay >/dev/null 2>&1; then
        return
    fi


echo "Instalando dependencias para yay..."

sudo pacman -S --needed --noconfirm base-devel git

echo "Instalando yay..."

sudo -u saul bash <<'EOF'

cd /tmp

rm -rf yay

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si --noconfirm

EOF

cd /tmp

rm -rf yay

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si --noconfirm

EOF

}


install_yay



###############################################################################
# AUR
###############################################################################

if [[ -f "$BACKUP_ROOT/aur-packages.txt" ]]; then

echo
echo "Restaurando AUR..."

mapfile -t AUR < "$BACKUP_ROOT/aur-packages.txt"


sudo -u saul bash <<EOF
yay -S --needed --noconfirm ${AUR[*]}
EOF


ok "AUR restaurado"

fi


###############################################################################
# Flatpak
###############################################################################

if [[ -f "$BACKUP_ROOT/flatpaks.txt" ]]; then

echo
echo "Restaurando Flatpaks..."


sudo -u saul flatpak remote-add --if-not-exists \
flathub \
https://flathub.org/repo/flathub.flatpakrepo || true


while IFS=$'\t' read -r APP ORIGIN; do

    [[ -z "$APP" ]] && continue
    [[ "$APP" == "Application" ]] && continue

    sudo -u saul flatpak install --user -y "$ORIGIN" "$APP" || true

done < "$BACKUP_ROOT/flatpaks.txt"


ok "Flatpaks restaurados"

fi



###############################################################################
# AutoSubs
###############################################################################

echo
echo "Instalando AutoSubs..."

if [[ -x "$SETUP_ROOT/scripts/08-autosubs.sh" ]]; then

    bash "$SETUP_ROOT/scripts/08-autosubs.sh"

    ok "AutoSubs listo"

else

    warn "AutoSubs no encontrado"

fi



###############################################################################
# Discos
###############################################################################

echo
echo "Configurando discos..."

if [[ -x "$SETUP_ROOT/scripts/11-drives.sh" ]]; then

    bash "$SETUP_ROOT/scripts/11-drives.sh" || true

    ok "Discos configurados"

fi



###############################################################################
# DaVinci
###############################################################################

echo
echo "Instalando DaVinci..."

export DAVINCI_BACKUP="$BACKUP_ROOT/davinci"


if [[ -x "$SETUP_ROOT/scripts/10-davinci.sh" ]]; then

    bash "$SETUP_ROOT/scripts/10-davinci.sh"

    ok "DaVinci terminado"

else

    warn "DaVinci no encontrado"

fi



###############################################################################
# Restaurar usuario
###############################################################################

echo
echo "Restaurando configuración..."

bash "$SETUP_ROOT/restore.sh" "$BACKUP_ROOT"


ok "Configuración restaurada"



###############################################################################
# Servicios
###############################################################################

echo
echo "Activando servicios..."

sudo loginctl enable-linger saul

sudo systemctl daemon-reload


sudo -u saul \
XDG_RUNTIME_DIR=/run/user/$(id -u saul) \
systemctl --user enable --now syncthing.service || true



###############################################################################
# Fuentes
###############################################################################

sudo -u saul fc-cache -f || true
sudo fc-cache -f || true



###############################################################################
# Montajes
###############################################################################

sudo systemctl daemon-reload

sudo mount -a || true


ls /mnt/SSD500 >/dev/null 2>&1 || true
ls /mnt/hddx201tb >/dev/null 2>&1 || true



###############################################################################
# Verificación
###############################################################################

echo
echo "Ejecutando verificación final..."


sudo -u saul \
XDG_RUNTIME_DIR=/run/user/$(id -u saul) \
bash "$SETUP_ROOT/scripts/14-verify.sh"



echo
echo "=========================================="
echo " RESTORE COMPLETADO"
echo "=========================================="

echo
echo "Reinicia el sistema."
