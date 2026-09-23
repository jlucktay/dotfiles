# GNU coreutils

macOS ships a BSD userland.
GNU builds are installed under a `g` prefix and are the first preference: they accept the long-form flags I ask for everywhere else, and they behave the way almost all documentation and examples describe.
A BSD tool handed a long flag either errors with `illegal option -- -` or, as with `ls --time-style=long-iso`, prints nothing at all and reads like an empty result rather than a mistake.

Coverage is uneven, so this is per-tool rather than a blanket "add a `g`".
Reaching for a `g` binary that isn't installed fails just as hard as the long flag did.

## Prefer the `g`-prefixed build

- **coreutils** — `gls`, `grm`, `gcp`, `gmv`, `gcat`, `ghead`, `gtail`, `gwc`, `gsort`, `guniq`, `gcut`, `gtr`, `gstat`, `gdate`, `gdu`, `gdf`, `gtouch`, `gmktemp`, `greadlink`, `grealpath`, `gtimeout`, `gseq`, `gsplit`, `gtee`, `gnproc`, `gshuf`, `gtac`, `gchmod`, `gchown`, `gln`, `gmkdir`, `gprintf` — the whole formula is installed, so any coreutils name exists under its `g` form.
- **`gsed`** — `/usr/bin/sed` is BSD, so `--in-place` and `--expression` both fail, and BSD `-i` demands an argument where GNU `-i` does not.
- **`gawk`** — `/usr/bin/awk` is BWK awk (`awk version 20200816`), not GNU; `--posix`, `--file` and GNU extensions need `gawk`.

## Do not prefix these — they already take long flags

- **`grep`** and **`find`** — Claude Code shadows both with its own embedded `ugrep -G` and `bfs`, which accept GNU long flags and GNU-style predicates such as `--ignore-case` and `-maxdepth`. Neither `ggrep` nor `gfind` is installed, so adding the prefix turns working commands into command-not-found.
- **`tar`** — libarchive's `tar` accepts `--create`, `--extract`, `--file=` and the rest of the GNU spelling.
- **`xargs`** — BSD, but it does take `--no-run-if-empty`; check the flag you actually want rather than assuming either dialect.

## No GNU build installed

There is no `gfind`, `gxargs`, `ggrep`, `gtar`, `gmake` or `gdiff` — the `findutils`, `grep`, `gnu-tar`, `make` and `diffutils` formulae are absent. Use the system tool and read its own flags.

## Portability boundary

- Code changes committed to any communal repo must not refer to any `g`-prefixed tools.
- Only ever seek out `g`-prefixed tools on this physical machine.
- Any virtualisation or remote-system-access layer will automatically void this rule.
