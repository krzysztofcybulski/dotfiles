#!/usr/bin/env bash
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then exit 0; fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="󰁹"; COLOR=0xff9ece6a ;;
  [6-8][0-9]) ICON="󰂀"; COLOR=0xff9ece6a ;;
  [3-5][0-9]) ICON="󰁾"; COLOR=0xffe0af68 ;;
  [1-2][0-9]) ICON="󰁻"; COLOR=0xffff9e64 ;;
  *)          ICON="󰂃"; COLOR=0xfff7768e ;;
esac

if [ -n "$CHARGING" ]; then ICON="󰂄"; COLOR=0xff7aa2f7; fi

sketchybar --set "$NAME" icon="$ICON" \
                         icon.color="$COLOR" \
                         label="${PERCENTAGE}%"
