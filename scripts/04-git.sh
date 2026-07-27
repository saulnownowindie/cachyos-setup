#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"
# CachyOS Setup - Módulo 04 (v2)
# Requiere que install.sh cargue lib/common.sh para las funciones:
# info ok warn error

sudo -v

info "Instalando Git y herramientas..."

sudo pacman -S --needed --noconfirm \
    git github-cli git-lfs openssh

git lfs install >/dev/null

info "Configurando Git..."

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global fetch.prune true
git config --global core.editor nano
git config --global core.autocrlf input
git config --global color.ui auto

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.last "log -1 HEAD --stat"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$KEY" ]]; then
    read -rp "Correo para la clave SSH: " EMAIL
    info "Generando clave SSH..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N ""
    ok "Clave SSH creada."
else
    ok "Clave SSH existente."
fi
chmod 600 "$KEY"
chmod 644 "$KEY.pub" 2>/dev/null || true
if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
fi

if ! ssh-add -l 2>/dev/null | grep -q "$(basename "$KEY")"; then
    ssh-add "$KEY" >/dev/null 2>&1 || true
fi

CONFIG="$HOME/.ssh/config"

if [[ ! -f "$CONFIG" ]] || ! grep -q "^Host github.com" "$CONFIG"; then
cat >>"$CONFIG" <<EOF

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
EOF
chmod 600 "$CONFIG"
fi

if ! gh auth status >/dev/null 2>&1; then
    info "Autenticando GitHub CLI..."
    gh auth login
fi

PUBKEY=$(cat "$KEY.pub")
SSH_KEYS="$(gh ssh-key list 2>/dev/null || true)"

if grep -Fq "$PUBKEY" <<<"$SSH_KEYS"; then
    ok "Clave SSH registrada en GitHub."
else
    info "Registrando clave SSH..."
    if ! gh ssh-key add "$KEY.pub" --title "$(hostname)" >/dev/null 2>&1; then
        warn "Solicitando permiso admin:public_key..."
        gh auth refresh -h github.com -s admin:public_key
        gh ssh-key add "$KEY.pub" --title "$(hostname)"
    fi
fi

info "Verificando autenticación SSH..."

SSH_OUTPUT="$(ssh -T git@github.com 2>&1 || true)"

if grep -qi "successfully authenticated" <<<"$SSH_OUTPUT"; then
    ok "Autenticación SSH correcta."
else
    warn "No fue posible verificar automáticamente la autenticación."
    echo "$SSH_OUTPUT"
fi

echo
echo "========================================="
echo " Estado"
echo "========================================="
echo "Git..................... OK"
echo "Git LFS................. OK"
echo "Configuración Git....... OK"
echo "SSH..................... OK"
echo "GitHub CLI.............. OK"
echo "========================================="
echo " MÓDULO 04 COMPLETADO"
echo "========================================="
