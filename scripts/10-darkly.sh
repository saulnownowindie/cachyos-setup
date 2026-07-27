#!/usr/bin/env bash

set -Eeuo pipefail


echo "=========================================="
echo " Instalando Darkly"
echo "=========================================="


WORKDIR="$HOME/.cache/cachyos-setup"
REPO="$WORKDIR/Darkly"
BUILD_DIR="$REPO/build"


sudo pacman -S --needed --noconfirm \
git \
cmake \
gcc \
extra-cmake-modules \
qt6-base \
qt6-declarative \
kdecoration


mkdir -p "$WORKDIR"


if [[ -d "$REPO/.git" ]]; then

    cd "$REPO"
    git pull --ff-only

else

    git clone https://github.com/Bali10050/Darkly.git "$REPO"
    cd "$REPO"

fi


mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"


cmake .. \
-DBUILD_QT6=ON \
-DBUILD_QT5=OFF


cmake --build . -j"$(nproc)"


sudo cmake --install .

kbuildsycoca6 || true

echo "Darkly instalado."
