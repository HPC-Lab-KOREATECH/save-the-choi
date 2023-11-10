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
            [ -z "$(is_container_running)" ] && docker start $CONTAINER_NAME
            ;;
        "idle")
            local idle_time_ms=$(xprintidle)
            local idle_time=$((idle_time_ms / 1000))
                          echo "333"
            if [ "$idle_time" -gt "$idle_threshold" ] && [ -z "$(is_container_running)" ]; then
              echo "111"
                docker start $CONTAINER_NAME
            elif [ "$idle_time" -le "$idle_threshold" ] && [ ! -z "$(is_container_running)" ]; then
              echo "222"
                docker stop $CONTAINER_NAME
            fi
            ;;
        "none")
            # 컨테이너가 실행 중이라면 중지합니다.
            [ ! -z "$(is_container_running)" ] && docker stop $CONTAINER_NAME
            ;;
        *)
            echo "Unknown mode: $mode"
            ;;
    esac
}

inotifywait -m -e close_write --format '%w%f' "$CONFIG_FILE" | while read file; do
    mode=$(jq -r '.mode' "$CONFIG_FILE")
    idle_threshold=$(jq -r '.idleThreshold' "$CONFIG_FILE")
    control_container "$mode" "$idle_threshold"
done &

while true; do
    echo "do"
    mode=$(jq -r '.mode' "$CONFIG_FILE")
    idle_threshold=$(jq -r '.idleThreshold' "$CONFIG_FILE")
    control_container "$mode" "$idle_threshold"
    sleep 1
done