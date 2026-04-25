#!/usr/bin/env bash
# Random Pokémon logo for fastfetch. ~1/128 shiny rate (canon encounter rate).
if (( RANDOM % 128 == 0 )); then
  exec krabby random -s
else
  exec krabby random
fi
