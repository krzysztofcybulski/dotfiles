#!/usr/bin/env bash
if [ "$SENDER" = "front_app_changed" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
