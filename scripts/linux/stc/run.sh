#!/bin/bash
if [ -n "$DISPLAY" ]; then
    tmux kill-session -t stc 2>/dev/null
    tmux new -d -s stc
    tmux send-keys -t stc "bash" C-m
    tmux send-keys -t stc "/opt/stc/core.sh" C-m
else
    echo "[stc] This is not a graphical session. Must be run in a graphical session."
fi