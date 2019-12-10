#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Background = white
coloursBackgroundWhite="$(tput setab 7)"
# Foreground = black
coloursForegroundBlack="$(tput setaf 0)"
# Reset colours
coloursReset="$(tput sgr0)"

# tput reset # this clears the screen; do not want

echo "before one"
echo "before two"
echo "Hello, $coloursBackgroundWhite${coloursForegroundBlack}world$coloursReset!"
echo "after one"
echo "after two"
