# Point the environment variable for the Application Default Credentials file at the correct one based on the Google Cloud CLI's currently active config.
if command -v gcloud &> /dev/null; then
  if _active_config=$(< "$HOME/.config/gcloud/active_config"); then
    _adc_file="$HOME/.config/gcloud/application_default_credentials.$_active_config.json"

    if [[ -r $_adc_file ]]; then
      export GOOGLE_APPLICATION_CREDENTIALS="$_adc_file"
    fi

    unset _adc_file
  fi

  unset _active_config
fi
