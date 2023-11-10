#!/bin/bash

config=$(jq '.mode = "always"' /opt/stc/config.json)
echo "$config" > /opt/stc/config.json
