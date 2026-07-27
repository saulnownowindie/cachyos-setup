#!/usr/bin/env bash
set -Eeuo pipefail

###############################################################################
# CachyOS Setup - Módulo 11
# Montaje automático de discos NTFS
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"



###############################################################################
# Dependencia NTFS
###############################################################################

if ! command -v mount.ntfs >/dev/null 2>&1; then

    info "Instalando soporte NTFS..."

    sudo pacman -S --needed --noconfirm ntfs-3g

fi



###############################################################################
# Detectar discos NTFS
###############################################################################

info "Detectando discos NTFS..."



mapfile -t DISKS < <(

lsblk -rpno NAME,FSTYPE,LABEL,UUID,MOUNTPOINT |
awk '$2 ~ /ntfs/ {print}'

)



if [[ ${#DISKS[@]} -eq 0 ]]; then

    warn "No se encontraron discos NTFS."

    exit 0

fi



echo
echo "Discos encontrados:"
echo


for i in "${!DISKS[@]}"; do

    read -r DEV FSTYPE LABEL UUID MOUNT <<< "${DISKS[$i]}"

    [[ -z "$LABEL" ]] && LABEL="$(basename "$DEV")"


    printf "[%s] %-15s %s\n" \
    "$((i+1))" \
    "$LABEL" \
    "$DEV"


done



echo

read -rp \
"¿Configurar montaje automático? [S/n]: " RESP


RESP=${RESP:-S}


[[ "$RESP" =~ ^[Nn]$ ]] && exit 0



###############################################################################
# Crear fstab
###############################################################################

for ENTRY in "${DISKS[@]}"; do


    read -r DEV FSTYPE LABEL UUID MOUNT <<< "$ENTRY"


    [[ -z "$LABEL" ]] && LABEL="$(basename "$DEV")"



    case "$LABEL" in


        "SSD 500GB")

            MOUNTPOINT="/mnt/SSD500"

        ;;


        "HDD 1TB")

            MOUNTPOINT="/mnt/hddx201tb"

        ;;


        *)

            SAFE=$(echo "$LABEL" \
            | tr '[:upper:]' '[:lower:]' \
            | tr ' ' '_' \
            | tr -cd 'a-z0-9_-')


            MOUNTPOINT="/mnt/$SAFE"

        ;;


    esac



    sudo mkdir -p "$MOUNTPOINT"



    if grep -q "$UUID" /etc/fstab; then


        ok "$LABEL ya configurado"


    else


        echo \
"UUID=$UUID $MOUNTPOINT ntfs-3g defaults,nofail,x-systemd.automount,uid=$(id -u),gid=$(id -g),umask=022 0 0" \
        | sudo tee -a /etc/fstab >/dev/null



        ok "$LABEL agregado"

    fi



done



###############################################################################
# Recargar systemd
###############################################################################

info "Recargando systemd..."

sudo systemctl daemon-reload



###############################################################################
# Montar
###############################################################################

info "Activando automontaje..."



sudo mount -a || true



echo

echo "=========================================="
echo " Discos configurados"
echo "=========================================="



findmnt | grep "/mnt/" || true



echo

ok "Módulo 11 finalizado."
