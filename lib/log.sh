#!/usr/bin/env bash
# lib/log.sh

LOG_DIR="$HOME/.local/state/cachyos-setup/logs"
LOG_FILE="$LOG_DIR/install.log"

init_log() {

    mkdir -p "$LOG_DIR"

    touch "$LOG_FILE"

}

start_module() {

    echo
    echo "==================================================" >>"$LOG_FILE"
    echo "$(date '+%F %T')  $1" >>"$LOG_FILE"

}

finish_module() {

    echo "$(date '+%F %T')  OK" >>"$LOG_FILE"

}

fail_module() {

    echo "$(date '+%F %T')  ERROR" >>"$LOG_FILE"

}