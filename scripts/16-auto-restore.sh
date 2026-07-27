#!/usr/bin/env bash
set -Eeuo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"


###############################################################################
# Funciones
###############################################################################

ok(){

    echo "[ OK ] $1"

}


warn(){

    echo "[WARN] $1"

}


fail(){

    echo "[FAIL] $1"
    exit 1

}



###############################################################################
# Inicio
###############################################################################

echo
echo "=========================================="
echo " Auto Restore CachyOS"
echo "=========================================="
echo



###############################################################################
# Buscar backup automáticamente
###############################################################################

echo "Buscando backup CachyOS..."


FOUND_BACKUP=""

TEMP_MOUNT="/mnt/cachy-search"


sudo mkdir -p "$TEMP_MOUNT"



PARTITIONS=$(lsblk -lnpo NAME,TYPE | awk '$2=="part"{print $1}')



for PART in $PARTITIONS; do


    echo "Probando: $PART"


    SEARCH_ROOT=""


    ###########################################################################
    # Usar montaje existente o montar temporalmente
    ###########################################################################

    CURRENT_MOUNT=$(findmnt -nr -o TARGET "$PART" || true)


    if [[ -n "$CURRENT_MOUNT" ]]; then


        SEARCH_ROOT="$CURRENT_MOUNT"


    else


        if sudo mount "$PART" "$TEMP_MOUNT" 2>/dev/null; then

            SEARCH_ROOT="$TEMP_MOUNT"

        else

            continue

        fi


    fi



    ###########################################################################
    # Buscar estructura del backup
    ###########################################################################

    if [[ -d "$SEARCH_ROOT/backups-cachyos/backups" ]] && \
       [[ -d "$SEARCH_ROOT/backups-cachyos/cachyos-setup" ]]; then


        FOUND_BACKUP="$SEARCH_ROOT/backups-cachyos"



    elif [[ -d "$SEARCH_ROOT/backups" ]] && \
         [[ -d "$SEARCH_ROOT/cachyos-setup" ]]; then


        FOUND_BACKUP="$SEARCH_ROOT"



    fi



    if [[ -n "$FOUND_BACKUP" ]]; then

        ok "Encontrado en $PART"
        break

    fi



    # Solo desmontar si este script montó el disco

    if [[ "$SEARCH_ROOT" == "$TEMP_MOUNT" ]]; then

        sudo umount "$TEMP_MOUNT"

    fi



done



if [[ -z "$FOUND_BACKUP" ]]; then

    fail "No se encontró backup CachyOS"

fi



###############################################################################
# Rutas
###############################################################################

BACKUP_ROOT="$FOUND_BACKUP/backups"

SETUP_ROOT="$FOUND_BACKUP/cachyos-setup"



ok "Backup:"
echo "$BACKUP_ROOT"


ok "Scripts:"
echo "$SETUP_ROOT"



###############################################################################
# Modo prueba
###############################################################################

if [[ "${1:-}" == "--test" ]]; then


    echo
    echo "=========================================="
    echo " MODO PRUEBA"
    echo "=========================================="


    echo
    echo "Backup detectado:"
    echo "$BACKUP_ROOT"


    echo
    echo "Setup detectado:"
    echo "$SETUP_ROOT"


    echo
    echo "Contenido backup:"
    ls -lah "$BACKUP_ROOT"


    echo
    echo "Prueba terminada."


    exit 0

fi



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
# Restaurar paquetes Pacman
###############################################################################

if [[ -f "$BACKUP_ROOT/packages.txt" ]]; then

    echo
    echo "Restaurando paquetes Pacman..."


    mapfile -t PACKAGES < "$BACKUP_ROOT/packages.txt"


    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"


    ok "Paquetes Pacman restaurados"

fi



###############################################################################
# Restaurar AUR
###############################################################################

if [[ -f "$BACKUP_ROOT/aur-packages.txt" ]]; then

    if command -v yay >/dev/null 2>&1; then

        echo
        echo "Restaurando AUR..."

        if [[ -s "$BACKUP_ROOT/aur-packages.txt" ]]; then

            mapfile -t AUR_PACKAGES < "$BACKUP_ROOT/aur-packages.txt"

            yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

            ok "AUR restaurado"

        else

            warn "No hay paquetes AUR para restaurar"

        fi

    else

        warn "yay no instalado"

    fi

fi


###############################################################################
# Restaurar Flatpak
###############################################################################

if [[ -f "$BACKUP_ROOT/flatpaks.txt" ]]; then


    echo
    echo "Restaurando Flatpaks..."


while IFS=$'\t' read -r APP ORIGIN; do

    [[ -z "$APP" ]] && continue
    [[ "$APP" == "Application" ]] && continue

    flatpak install -y "$ORIGIN" "$APP" || true

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

    ok "AutoSubs instalado"

else

    warn "No se encontró módulo AutoSubs"

fi

###############################################################################
# Discos
###############################################################################

echo
echo "Configurando discos..."


if [[ -x "$SETUP_ROOT/scripts/11-drives.sh" ]]; then

    bash "$SETUP_ROOT/scripts/11-drives.sh"

    ok "Discos configurados"

else

    warn "No se encontró módulo de discos"

fi

###############################################################################
# DaVinci Resolve
###############################################################################

echo
echo "Restaurando DaVinci Resolve..."


export DAVINCI_BACKUP="$BACKUP_ROOT/davinci"


if [[ -x "$SETUP_ROOT/scripts/10-davinci.sh" ]]; then

    bash "$SETUP_ROOT/scripts/10-davinci.sh"

    ok "DaVinci procesado"

else

    warn "No se encontró instalador DaVinci"

fi
###############################################################################
# Configuración usuario
###############################################################################

echo
echo "Restaurando configuración..."


bash "$SETUP_ROOT/restore.sh" "$BACKUP_ROOT"


ok "Configuración restaurada"

###############################################################################
# Activar servicios usuario
###############################################################################

echo
echo "Activando servicios usuario..."

sudo loginctl enable-linger saul
sudo systemctl daemon-reload


sudo -u saul \
XDG_RUNTIME_DIR=/run/user/$(id -u saul) \
systemctl --user enable --now syncthing.service || true
###############################################################################
# Verificación final
###############################################################################

echo
echo "Ejecutando verificación final..."


###############################################################################
# Recargar montajes
###############################################################################

echo "Recargando montajes..."

sudo systemctl daemon-reload

sudo udevadm settle --timeout=30

sudo mount -a


###############################################################################
# Activar automount
###############################################################################

echo "Activando automontajes..."


# Forzar activación de los puntos automount
ls /mnt/SSD500 >/dev/null 2>&1 || true
ls /mnt/hddx201tb >/dev/null 2>&1 || true


###############################################################################
# Fuentes
###############################################################################

echo "Actualizando caché de fuentes usuario..."


sudo -u saul fc-cache -f -v >/dev/null 2>&1 || true

sleep 3
###############################################################################
# Esperar servicios y discos
###############################################################################
echo "Esperando discos..."


for i in {1..60}; do

    if mountpoint -q /mnt/hddx201tb; then
        break
    fi

    sudo udevadm settle --timeout=5 2>/dev/null || true
    sudo mount -a 2>/dev/null || true

    sleep 1

done

if ! mountpoint -q /mnt/hddx201tb; then
    warn "No se pudo montar /mnt/hddx201tb tras 30s de espera"
fi


echo "Esperando servicios..."

sleep 5

###############################################################################
# Verificación final real
###############################################################################

sudo -u saul \
XDG_RUNTIME_DIR=/run/user/$(id -u saul) \
bash "$SETUP_ROOT/scripts/14-verify.sh"
echo
echo "=========================================="
echo " RESTORE COMPLETADO"
echo "=========================================="
echo
echo "Reinicia el sistema."
