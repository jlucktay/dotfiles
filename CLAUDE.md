# dotfiles

A [chezmoi](https://www.chezmoi.io/) source directory. This file guides work inside the repo itself; it is ignored as a target and never deployed.

The machine-wide agent instructions live in `dot_config/literal__agents/AGENTS.md` and its `rules/` directory, deployed to `~/.config/_agents/`. Claude Code reaches them through the `~/.claude/CLAUDE.md` and `~/.claude/rules` symlinks, and Gemini through the matching links under `~/.gemini/`.

## Edit source state, never the target

- Change files here, then apply. A file edited under `$HOME` is overwritten by the next `chezmoi apply`.
- Several targets are symlinks into other targets, so an edit through `~/.claude/CLAUDE.md` or `~/.claude/rules/` lands in `~/.config/_agents/` and is still a target edit.
- Source names carry attributes: `dot_` becomes a leading `.`, `private_` sets owner-only permissions, `executable_` sets the execute bit, `symlink_` makes a symlink whose target is the file's content, `literal_` stops attribute parsing (`literal__agents` becomes `_agents`), and a `.tmpl` suffix renders the file as a Go template.
- `.chezmoiignore` and `.chezmoiremove` match target paths, not source paths.
- `.chezmoiignore` wins over `.chezmoiremove`: a target listed in both is left in place, so never ignore a target that is meant to be removed. A file at the source root always maps to a target of the same name in `$HOME`, which is why this file is `CLAUDE.md` rather than `AGENTS.md`.

## Machine pivots

Templates branch on one of two signals; follow whichever the file being edited already uses.

- Hostname: `{{ if eq (printf "%.4s" .chezmoi.hostname | lower) "ovo-" }}` for the work machine.
- Profile: `.profile` from `.chezmoidata.yaml`, validated against `chezmoidata.schema.json`.

## Externals

- Each `.chezmoiexternal.*` entry pins an upstream commit in its URL and the archive's `sha256` in `checksum`. Bump both together, or the apply fails on the checksum.
- Compute a new checksum with `curl --fail --location --silent <url> | sha256sum`.
- `chezmoi re-add` skips every target that comes from an external. In a directory that mixes both, such as `~/.local/share/ghostty-blackhole/`, `chezmoi managed --include=externals` and `--exclude=externals` show which mechanism owns each target, and only the source-state files can be re-added.

## Before applying

- Preview with `chezmoi diff`. From a git worktree of this repo, `chezmoi --source=<worktree> diff` renders that checkout against the live home directory without touching the real source directory.
- Render a template on its own with `chezmoi execute-template < <file>.tmpl`, and pipe JSON output through `jq .` to catch comma mistakes around conditional blocks.
- Shell scripts must pass the shellcheck settings in `.pre-commit-config.yaml`.

## Portability

- Committed scripts must not call `g`-prefixed GNU tools such as `gsed` or `gls`; those exist only on one macOS machine.
- Anything that depends on macOS is excluded on other systems through `.chezmoiignore` or a template guard.
