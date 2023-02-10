# Dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Bootstrap

Run this to bootstrap a new environment:

``` shell
curl --fail --location --silent https://raw.githubusercontent.com/jlucktay/dotfiles/main/bootstrap.sh | bash
```

Set `CHEZMOI_PURGE=1` on the script execution to remove Chezmoi's source/config directories after initialising and
applying:

``` shell
curl --fail --location --silent https://raw.githubusercontent.com/jlucktay/dotfiles/main/bootstrap.sh \
  | CHEZMOI_PURGE=1 bash
```

### Reminders

On macOS, after installing a modern version of Bash (probably with Homebrew) don't forget to (re)set the default shell, so that desktop/UI apps inherit all of the things from the Bash profile.

First, append the path of the Homebrew-managed Bash binary to the list of available shells:

```shell
echo "${package_manager_prefix:?}/bin/bash" | sudo tee -a /etc/shells
```

Next, use `chsh` to set it as your new default:

```shell
chsh -s "${package_manager_prefix:?}/bin/bash"
```

Finally, reboot, and rejoice!
