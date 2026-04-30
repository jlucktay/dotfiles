if ! command -v profile-switch.sh &> /dev/null; then
	return 0
fi

function _profile_switch() {
	# Get valid values for 'profile' from the enum in the schema.
	local chezmoidata_schema_enum
	chezmoidata_schema_enum=$(jq --exit-status --raw-output '.properties.profile.enum[]' "$HOME/.local/share/chezmoi/chezmoidata.schema.json")

	# Generate possible completions with chezmoidata schema enums.
	local compgen_cdse
	compgen_cdse=$(compgen -W "$chezmoidata_schema_enum" -- "$2")

	# Store possible completions for 'complete' to make use of.
	mapfile -t COMPREPLY <<< "$compgen_cdse"
}

complete -F _profile_switch profile-switch.sh
