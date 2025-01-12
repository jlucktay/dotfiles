if command -v topgrade &> /dev/null; then
  function topgrade_only() {
    local -
    set -o pipefail

    yq_output=$(yq --output-format=yaml '.misc.only' "$HOME"/.config/topgrade.toml)
    mapfile -t topgrade_misc_only <<< "$yq_output"

    only="${1:?"must pass an argument for the 'only' Topgrade section to run, valid options:
$yq_output"}"

    # Strip '- ' prefix from every element.
    topgrade_misc_only=("${topgrade_misc_only[@]#'- '}")

    declare only_found_in_config=0

    for i in "${topgrade_misc_only[@]}"; do
      if [[ $i == "$only" ]]; then
        only_found_in_config=1
      fi
    done

    if [[ $only_found_in_config -eq 0 ]]; then
      echo >&2 "'$only' is not set in the '.misc.only' section of the Topgrade config file."
      echo >&2 "Valid options are:"
      echo >&2 "$yq_output"

      return 1
    fi

    declare -a topgrade_disable_flags=()

    for ((i = 0; i < ${#topgrade_misc_only[@]}; i++)); do
      if [[ ${topgrade_misc_only[i]} != "$only" ]]; then
        topgrade_disable_flags+=(--disable="${topgrade_misc_only[i]}")
      fi
    done

    set -x
    topgrade --only="$only" "${topgrade_disable_flags[@]}"
  }

  export -f topgrade_only
fi
