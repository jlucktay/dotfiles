# Dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Bootstrap

Run this to bootstrap a new environment:

``` shell
curl --fail --location --silent https://git.io/jlucktay-dotfiles | bash
```

Set `CHEZMOI_PURGE=1` on the script execution to remove Chezmoi's source/config directories after initialising and
applying:

``` shell
curl --fail --location --silent https://git.io/jlucktay-dotfiles | CHEZMOI_PURGE=1 bash
```
