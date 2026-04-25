#!/usr/bin/env bash
# Highlight workspace item if focused.
# Called as: aerospace.sh <workspace-id>

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           label.color=0xff1a1b26
else
  sketchybar --set "$NAME" background.drawing=off \
                           label.color=0xffc0caf5
fi
