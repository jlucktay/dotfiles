if command -v topgrade &> /dev/null; then
  function topgrade_only() {
    local -
    set -o pipefail

    only="${1:?'must pass an argument for the "only" Topgrade section to run'}"

    yq_output=$(yq --output-format=yaml '.misc.only' "$HOME"/.config/topgrade.toml)
    mapfile -t topgrade_misc_only <<< "$yq_output"

    # Strip '- ' prefix from every element.
    topgrade_misc_only=("${topgrade_misc_only[@]#'- '}")

    if ! [[ ${topgrade_misc_only[*]} =~ $only ]]; then
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
    topgrade --only "$only" "${topgrade_disable_flags[@]}"
  }

  export -f topgrade_only
fi
