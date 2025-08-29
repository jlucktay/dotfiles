# Point the environment variable for the Application Default Credentials file at the correct one based on the Google Cloud CLI's currently active config.
if command -v gcloud &> /dev/null; then
  if _active_config=$(< "$HOME/.config/gcloud/active_config"); then
    _adc_file="$HOME/.config/gcloud/application_default_credentials.$_active_config.json"

    if [[ -r $_adc_file ]]; then
      export GOOGLE_APPLICATION_CREDENTIALS="$_adc_file"
    fi

    unset _adc_file
  fi

  if [[ $_active_config == "ovo" ]]; then
    _gc_cfg_cccf_empty=0

    if ! _gc_cfg_cccf=$(gcloud config get core/custom_ca_certs_file --format=json 2> /dev/null); then
      _gc_cfg_cccf_empty=1
    elif [[ -z $_gc_cfg_cccf ]] || [[ $_gc_cfg_cccf == '[]' ]]; then
      _gc_cfg_cccf_empty=1
    fi

    if [[ $_gc_cfg_cccf_empty -eq 1 ]]; then
      echo >&2 "❌ the 'core/custom_ca_certs_file' config needs to be set for 'gcloud': https://ovotech.atlassian.net/wiki/spaces/OTKB/pages/4596302401"
    fi

    unset _gc_cfg_cccf_empty _gc_cfg_cccf
  fi

  unset _active_config
fi
