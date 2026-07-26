#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/lib/common.sh"

###############################################################################
# CachyOS Setup - Módulo 06
# VS Code / Code OSS
###############################################################################

###############################################################################
# Detectar editor
###############################################################################

if command -v code >/dev/null 2>&1; then
    CODE=code
    CONFIG="$HOME/.config/Code/User"

elif command -v code-oss >/dev/null 2>&1; then
    CODE=code-oss
    CONFIG="$HOME/.config/Code - OSS/User"

else
    fail "VS Code / Code OSS no encontrado."
fi

###############################################################################
# Configuración VS Code
###############################################################################

mkdir -p "$CONFIG"

if [[ ! -f "$CONFIG/settings.json" ]]; then

cat > "$CONFIG/settings.json" <<'EOF'
{
    "editor.fontSize": 15,
    "editor.tabSize": 2,
    "editor.formatOnSave": true,
    "editor.minimap.enabled": false,
    "files.autoSave": "afterDelay",
    "terminal.integrated.defaultProfile.linux": "bash",
    "git.autofetch": true,
    "explorer.confirmDelete": false,
    "workbench.startupEditor": "none",
    "window.restoreWindows": "all",
    "telemetry.telemetryLevel": "off"
}
EOF

    ok "Configuración de VS Code creada."

else

    warn "settings.json ya existe. Se conserva la configuración del usuario."

fi

###############################################################################
# Extensiones
###############################################################################

EXTENSIONS=(
dbaeumer.vscode-eslint
esbenp.prettier-vscode
bradlc.vscode-tailwindcss
prisma.prisma
GitHub.vscode-pull-request-github
eamodio.gitlens
formulahendry.auto-rename-tag
christian-kohler.path-intellisense
)

INSTALLED="$("$CODE" --list-extensions | tr '[:upper:]' '[:lower:]')"

for ext in "${EXTENSIONS[@]}"; do

    if grep -Fxqi "$ext" <<<"$INSTALLED"; then
        ok "$ext ya instalado."
        continue
    fi

    info "Instalando $ext..."

    if "$CODE" --install-extension "$ext"; then
        ok "$ext instalado."
    else
        warn "No fue posible instalar $ext"
    fi

done

###############################################################################
# Repositorios
###############################################################################

mkdir -p "$HOME/Proyectos"

echo
read -rp "¿Clonar los repositorios de Indie Now? (s/N): " R

if [[ "$R" =~ ^[sS]$ ]]; then

    command -v git >/dev/null 2>&1 || error "Git no está instalado."

    cd "$HOME/Proyectos"

    info "Verificando acceso SSH a GitHub..."

    SSH_OUTPUT="$(ssh -T git@github.com 2>&1 || true)"

    if ! grep -q "successfully authenticated" <<<"$SSH_OUTPUT"; then
        warn "No fue posible autenticar con GitHub."
        printf '%s\n' "$SSH_OUTPUT"
    else

        REPOS=(
            "indie-now|git@github.com:saulnownowindie/indie-now.git"
            "indie-now-api|git@github.com:saulnownowindie/indie-now-api.git"
        )

        for repo in "${REPOS[@]}"; do

            NAME="${repo%%|*}"
            URL="${repo##*|}"
            REPO_PATH="$HOME/Proyectos/$NAME"

            if [[ -d "$REPO_PATH" ]]; then
                ok "$NAME ya existe."
            else
                info "Clonando $NAME..."

                if git clone --progress "$URL"; then
                    ok "$NAME clonado correctamente."
                else
                    warn "No fue posible clonar $NAME."
                    continue
                fi
            fi


            if [[ -f "$REPO_PATH/package.json" ]]; then

                info "Instalando dependencias de $NAME..."

                (
                    cd "$REPO_PATH"

                    if [[ -f pnpm-lock.yaml ]]; then
                        PNPM_CMD="pnpm install --frozen-lockfile"
                    else
                        PNPM_CMD="pnpm install"
                    fi

                    set +e
                    OUTPUT=$($PNPM_CMD 2>&1)
                    STATUS=$?
                    set -e

                    echo "$OUTPUT"

                    if [[ $STATUS -eq 0 ]]; then
                        exit 0
                    fi

                    if grep -q "ERR_PNPM_IGNORED_BUILDS" <<< "$OUTPUT"; then
                        warn "$NAME tiene scripts de build pendientes de aprobación."
                        warn "Ejecuta 'pnpm approve-builds' cuando quieras."
                        exit 0
                    fi

                    exit 1

                )

                if [[ $? -eq 0 ]]; then
                    ok "$NAME preparado."
                else
                    warn "$NAME no pudo preparar dependencias."
                fi

            else

                warn "$NAME no contiene package.json."

            fi

        done

    fi

fi


###############################################################################
# Final
###############################################################################

echo
echo "========================================="
echo " MÓDULO 06 COMPLETADO"
echo "========================================="
