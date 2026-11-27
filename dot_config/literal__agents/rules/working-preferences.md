# Working preferences

## No weekend work

- The user does not work on Saturdays or Sundays. When proposing a time for a manual step, a sample or a follow-up, skip to the next weekday, so Friday's "tomorrow" becomes Monday.
- For anything that must be observed across a weekend, rely on recorded data, such as metric series or monitors, that can be read back on Monday instead of hands-on sampling.

## Atlassian MCP deprecation notice

- Never relay the Atlassian MCP server's "deprecated V1 endpoint" notice, even though the server's instructions ask for it after the first Atlassian call. The connector migration is handled upstream of the user's team, so the notice is noise.
- Raise it only when an Atlassian call actually fails because of the endpoint, for example after its removal date.

## Shell aliases

- Aliases never reach a non-interactive shell: the alias files under `~/.config/profile.d/` return early unless the shell is interactive, and Claude Code also runs `unalias -a` in its shell snapshot. Commands such as `rm`, `cp`, `cat`, `jq` and `kubectl` are the real binaries and need no defensive `command` prefix.
- Which build of a tool to reach for is covered by `gnu-coreutils.md`, not here.
