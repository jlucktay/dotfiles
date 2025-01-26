# Point the environment variable for the Application Default Credentials file at the correct one based on the currently
# active config in the Google Cloud CLI.
if command -v gcloud &> /dev/null; then
  _active_config=$(gcloud config configurations list --filter="is_active:true" --format="value(name)")
  _adc_file="$HOME/.config/gcloud/application_default_credentials.$_active_config.json"

  if [[ -r $_adc_file ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$_adc_file"
  fi

  unset _active_config _adc_file
fi
