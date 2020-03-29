#!/usr/bin/env bash
for R in $(seq 0 32 255); do
  for G in $(seq 0 32 255); do
    for B in $(seq 0 32 255); do
      printf "\e[38;2;%s;%s;%sm█\e[0m" "$R" "$G" "$B"
    done
  done
  echo
done
