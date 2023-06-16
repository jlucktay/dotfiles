# Point the environment variable for the Application Default Credentials file at the correct one based on the currently
# active config in the Google Cloud CLI.
if command -v gcloud &> /dev/null && command -v jq &> /dev/null; then
  config_list=$(gcloud config configurations list --format=json)
  active_config=$(jq --raw-output '.[] | select( .is_active == true ) | .name' <<< "$config_list")
  adc_file="$HOME/.config/gcloud/application_default_credentials.$active_config.json"

  if [[ -r $adc_file ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$adc_file"
  fi
fi
