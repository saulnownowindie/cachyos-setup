#!/usr/bin/env bash
# lib/lock.sh

LOCK_DIR="/tmp/cachyos-setup.lock"

acquire_lock() {

    if mkdir "$LOCK_DIR" 2>/dev/null; then

        trap 'release_lock' EXIT INT TERM

        return 0

    fi

    echo
    echo "Ya existe otra instancia del instalador ejecutándose."
    echo

    exit 1

}

release_lock() {

    rm -rf "$LOCK_DIR"

}