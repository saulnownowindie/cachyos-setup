# CachyOS Creator & Gaming Workstation Installer

## Convierte una instalación limpia de CachyOS en una estación de trabajo para creación, edición y gaming.

Creado por:

**Saúl González**  
Editor audiovisual y parte de **Indie Now**

Instagram:
https://instagram.com/saulnownow

Indie Now:
https://instagram.com/indienownow

---

# ¿Qué es?

CachyOS Creator & Gaming Workstation Installer es un conjunto de scripts Bash para preparar automáticamente un sistema Linux con:

- CachyOS
- KDE Plasma
- NVIDIA
- Wayland

Transforma una instalación limpia en un entorno preparado para:

- 🎬 Edición de vídeo
- 🎵 Producción audiovisual
- 🎮 Gaming
- 💻 Desarrollo
- 📂 Trabajo diario

---

# Características

## 🎬 Creación de contenido

Incluye herramientas para creadores:

- DaVinci Resolve (Free/Studio)
- AutoSubs para subtítulos automáticos
- FFmpeg
- OBS Studio
- Kdenlive
- GIMP
- Inkscape

Pensado para trabajar con:

- iPhone
- Cámaras 4K
- Redes sociales
- Edición profesional

---

## 🎮 Gaming

Configura un entorno preparado para juegos:

- Steam
- Proton
- Vulkan
- GameMode
- MangoHUD
- Heroic Games Launcher

Optimizado para:

- NVIDIA
- GPUs modernas
- Juegos Linux y Windows mediante Proton

---

## 🖥️ NVIDIA y DaVinci Resolve

El instalador verifica NVIDIA antes de modificar el sistema.

Incluye preparación para:

- Drivers propietarios
- Vulkan
- CUDA
- DaVinci Resolve en Linux

DaVinci utiliza el instalador oficial `.run`.

Si no está disponible, el módulo continúa sin bloquear la instalación.

---

## 🧠 AutoSubs

Integración para generación automática de subtítulos mediante IA.

Incluye:

- Instalación automática
- Integración con DaVinci Resolve
- Compatibilidad Free y Studio

---

## 💻 Desarrollo

Prepara un entorno moderno:

- Git
- GitHub CLI
- Node.js
- npm
- pnpm
- Bun
- Docker
- VS Code

---

## 🔄 Sincronización y backups

Incluye:

- Syncthing
- Backup de configuraciones importantes

Permite restaurar:

- Git
- SSH
- VS Code
- Fish
- DaVinci Resolve

---

# Instalación

```bash
git clone https://github.com/saulnownowindie/cachyos-setup.git

cd cachyos-setup

bash install.sh
```

---

# Módulos

```
01 - Sistema base
02 - Paquetes esenciales
03 - Flatpak
04 - Git y GitHub
05 - Node / Desarrollo
06 - VS Code
07 - KDE Plasma
08 - AutoSubs
09 - Syncthing
10 - DaVinci Resolve
11 - Discos y montaje
12 - Workspace de desarrollo
13 - Backup
14 - Verificación final
```

---

# Verificación final

El instalador comprueba:

- Software instalado
- NVIDIA
- DaVinci Resolve
- AutoSubs
- Syncthing
- KDE Plasma
- Discos configurados

Resultado esperado:

```
OK   : 14
WARN : 0
FAIL : 0
```

---

# Requisitos

Recomendado:

- CachyOS
- KDE Plasma
- NVIDIA
- Usuario con sudo

---

# Estado del proyecto

✅ Instalador modular  
✅ Ejecución repetible  
✅ Backup y restauración  
✅ Validación automática  
✅ Preparado para creación y gaming

INICAR

sudo pacman -Syu
git clone git@github.com:saulnownowindie/cachyos-setup.git
cd cachyos-setup
bash install.sh
