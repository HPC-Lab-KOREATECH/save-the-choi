#!/bin/sh

user=$(logname)
raw_home=$(getent passwd "$user" | cut -d: -f6)
home=$(realpath -s "$raw_home")
rm -rf "$home/.config/autostart/stc.desktop"
rm -rf /opt/stc