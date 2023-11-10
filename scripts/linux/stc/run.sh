#!/bin/bash

MODE=$(jq -r '.mode' /opt/stc/config.json)
IDLE_THRESHOLD=$(jq -r '.idleThreshold' /opt/stc/config.json)
CONFIG_FILE="/opt/stc/config.json"
DOCKER_CONFIG_FILE="/opt/stc/docker-config.json"
CONTAINER_NAME="stc-container"

cleanup() {
    pkill -P $$
}
trap cleanup EXIT

is_container_running() {
    docker ps -f "name=$CONTAINER_NAME" --format "{{.Names}}"
}

control_container() {
    local mode=$1
    local idle_threshold=$2
    case $mode in
        "always")
            if [ -z "$(is_container_running)" ]; then
              echo "[stc] (always) Start container"
              docker start $CONTAINER_NAME
            fi
            ;;
        "idle")
            local idle_time_ms=$(xprintidle)
            local idle_time=$((idle_time_ms / 1000))
            if [ "$idle_time" -gt "$idle_threshold" ] && [ -z "$(is_container_running)" ]; then
                echo "[stc] (idle) Start container"
                docker start $CONTAINER_NAME
            elif [ "$idle_time" -le "$idle_threshold" ] && [ ! -z "$(is_container_running)" ]; then
                echo "[stc] (idle) Stop container"
                docker stop $CONTAINER_NAME
            fi
            ;;
        "none")
            if [ ! -z "$(is_container_running)" ]; then
              echo "[stc] (always) Stop container"
              docker stop $CONTAINER_NAME
            fi
            ;;
        *)
            echo "Unknown mode: $mode"
            ;;
    esac
}

while true; do
    mode=$(jq -r '.mode' "$CONFIG_FILE")
    idle_threshold=$(jq -r '.idleThreshold' "$CONFIG_FILE")
    control_container "$mode" "$idle_threshold"
    sleep 1
done