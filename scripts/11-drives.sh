#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

# CachyOS Setup - Módulo 09 (v2)
# Montaje automático de discos NTFS

sudo -v

info "Detectando discos de datos..."

mapfile -t DISKS < <(
lsblk -rpno NAME,FSTYPE,LABEL,UUID,MOUNTPOINT |
awk '$2 ~ /ntfs|ntfs3/ {print}'
)

if [[ ${#DISKS[@]} -eq 0 ]]; then
    warn "No se encontraron discos NTFS."
    exit 0
fi

echo
echo "Se detectaron los siguientes discos:"
echo

for i in "${!DISKS[@]}"; do
    read -r DEV FSTYPE LABEL UUID MOUNT <<<"${DISKS[$i]}"
    [[ -z "$LABEL" ]] && LABEL="$(basename "$DEV")"
    printf "[%d] %-12s %-8s %s\n" "$((i+1))" "$LABEL" "$FSTYPE" "$DEV"
done

echo
read -rp "¿Montar automáticamente todos los discos detectados? [S/n]: " RESP
RESP=${RESP:-S}

[[ "$RESP" =~ ^[Nn]$ ]] && exit 0

for ENTRY in "${DISKS[@]}"; do

    read -r DEV FSTYPE LABEL UUID MOUNT <<<"$ENTRY"

    [[ -z "$LABEL" ]] && LABEL="$(basename "$DEV")"

    SAFE=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_-')

    MOUNTPOINT="/mnt/$SAFE"

    sudo mkdir -p "$MOUNTPOINT"

    if grep -q "$UUID" /etc/fstab; then
        ok "$LABEL ya está configurado."
    else
        echo "UUID=$UUID $MOUNTPOINT ntfs3 defaults,uid=$(id -u),gid=$(id -g),nofail 0 0" \
        | sudo tee -a /etc/fstab >/dev/null

        ok "$LABEL agregado a /etc/fstab."
    fi
done

info "Recargando configuración de systemd..."
sudo systemctl daemon-reload


info "Montando discos..."

sudo mount -a

echo
echo "========================================="
echo " Discos montados"
echo "========================================="

mount | grep "/mnt/" || true

echo
ok "Módulo 11 finalizado."
