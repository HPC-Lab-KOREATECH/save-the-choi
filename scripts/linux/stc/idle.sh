#!/bin/bash

idleThreshold=${1:-300}
config=$(jq --arg idleThreshold "$idleThreshold" '.mode = "idle" | .idleThreshold = ($idleThreshold | tonumber)' /opt/stc/config.json)
echo "$config" > /opt/stc/config.json