#!/bin/bash

config=$(jq '.mode = "none"' /opt/stc/config.json)
echo "$config" > /opt/stc/config.json