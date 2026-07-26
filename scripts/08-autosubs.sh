#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"


echo "=========================================="
echo " AutoSubs"
echo "=========================================="


echo
echo "Instalando dependencias..."


sudo pacman -S --needed --noconfirm \
rpmextract \
wget \
curl \
ffmpeg \
xorg-xwayland \
python \
webkit2gtk-4.1



INSTALL_DIR="$HOME/AutoSubs-install"



mkdir -p "$INSTALL_DIR"

cd "$INSTALL_DIR"



echo
echo "Descargando AutoSubs..."


wget -O AutoSubs.rpm \
https://github.com/tmoroney/auto-subs/releases/latest/download/AutoSubs-linux-x86_64.rpm



echo
echo "Extrayendo paquete..."


rm -rf usr opt


rpmextract.sh AutoSubs.rpm



echo
echo "Instalando archivos..."


sudo cp -r usr/* /usr/


if [[ -d opt ]]; then

    sudo cp -r opt/* /opt/

fi



echo
echo "Configurando compatibilidad gráfica AutoSubs..."



if [[ -f /usr/bin/autosubs-real ]]; then

    echo "✓ Binario original ya separado"


elif [[ -f /usr/bin/autosubs ]]; then

    echo "Separando binario original..."

    sudo mv /usr/bin/autosubs /usr/bin/autosubs-real


else

    echo "⚠ No se encontró binario AutoSubs"

fi



if [[ -f /usr/bin/autosubs-real ]]; then


    sudo tee /usr/bin/autosubs > /dev/null <<'EOF'
#!/usr/bin/env bash

export GDK_BACKEND=x11
export WEBKIT_DISABLE_DMABUF_RENDERER=1

exec /usr/bin/autosubs-real "$@"
EOF


    sudo chmod +x /usr/bin/autosubs


    echo "✓ Launcher AutoSubs configurado para Wayland/NVIDIA"


fi



echo
echo "Instalando integración DaVinci Resolve..."



if [[ -f "$INSTALL_DIR/opt/resolve/Fusion/Scripts/Utility/AutoSubs.lua" ]]; then


    sudo mkdir -p \
    /opt/resolve/Fusion/Scripts/Utility


    sudo cp \
    "$INSTALL_DIR/opt/resolve/Fusion/Scripts/Utility/AutoSubs.lua" \
    /opt/resolve/Fusion/Scripts/Utility/


    echo "✓ Script Fusion AutoSubs instalado"


else

    echo "⚠ Script Fusion AutoSubs no encontrado"

fi



echo
echo "Eliminando launcher antiguo..."


rm -f "$HOME/.local/bin/autosubs"



echo
echo "Verificando instalación..."



if command -v autosubs >/dev/null 2>&1; then

    echo "✓ AutoSubs instalado"

else

    echo "✗ AutoSubs no encontrado"

fi



echo
echo "Comprobando rutas..."



if [[ -f /usr/bin/autosubs-real ]]; then

    echo "✓ Binario original AutoSubs encontrado"

fi



if [[ -f /usr/bin/autosubs ]]; then

    echo "✓ Wrapper AutoSubs encontrado"

fi



if [[ -f /opt/resolve/Fusion/Scripts/Utility/AutoSubs.lua ]]; then

    echo "✓ Integración DaVinci encontrada"

fi



echo
echo "=========================================="
echo " AutoSubs instalado correctamente"
echo "=========================================="


echo
echo "Ejecutar con:"
echo
echo "autosubs"
