# https://support.1password.com/command-line/

if hash op 2>/dev/null && hash jq 2>/dev/null; then
    # two fields: 'age' is epoch seconds, 'session' is 1Password's session ID
    json_path=$HOME/.config/op/temp.json

    if test -f "$json_path"; then
        epoch_age=$( jq '.age' "$json_path" )
    else
        epoch_age=0
    fi

    epoch_now=$( date +'%s' )
    session_age=$(( epoch_now - epoch_age ))

    if (( session_age > 1800 )); then
        # too old; need a new session
        new_session=$( op signin my --output=raw )
        export OP_SESSION_my=$new_session

        # persist new details out to JSON file
        mkdir -p "$( dirname "$json_path" )"
        echo "{ \"age\": $epoch_now, \"session\":\"$new_session\" }" | jq > "$json_path"
    else
        # session still younger than 30 minutes
        OP_SESSION_my=$( jq -r .session "$json_path" )
        export OP_SESSION_my
    fi
fi
