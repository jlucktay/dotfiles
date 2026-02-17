#!/usr/bin/env bash

sequence="$(seq 0 32 255)"

for R in "${sequence[@]}"; do
	for G in "${sequence[@]}"; do
		for B in "${sequence[@]}"; do
			printf "\e[38;2;%s;%s;%sm█\e[0m" "$R" "$G" "$B"
		done
	done
	echo
done
