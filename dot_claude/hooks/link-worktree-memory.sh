#!/usr/bin/env bash
set -uo pipefail

# PostToolUse:EnterWorktree — point a new worktree's memory store at its repo's shared store, so worktree sessions read and write the same memories as the main checkout.
#
# Opt in per repo by creating its store directory once:
#   mkdir -p ~/.claude/memory-stores/<repo-dir-name>
# With no such directory the hook is a no-op, so it stays inert for every repo you have not deliberately enabled.
#
# Contract confirmed empirically 2026-09-04: PostToolUse fires for EnterWorktree, and both .cwd and .transcript_path in the payload are post-switch — so the project directory is the transcript's parent and never needs deriving from the path slug.

payload="$(cat 2> /dev/null || true)"

# The project directory is wherever the runtime is already writing the transcript.
transcript="$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2> /dev/null)" || exit 0
[[ -n $transcript ]] || exit 0

proj_dir="$(dirname "$transcript")"
[[ -d $proj_dir ]] || exit 0

worktree="$(printf '%s' "$payload" | jq -r '.tool_response.worktreePath // .cwd // empty' 2> /dev/null)" || exit 0
[[ -n $worktree ]] || exit 0

# The canonical repo root, independent of where this session started.
common="$(git -C "$worktree" rev-parse --path-format=absolute --git-common-dir 2> /dev/null)" || exit 0
repo_root="$(dirname "$common")"
[[ $repo_root != "$worktree" ]] || exit 0 # in the main checkout; nothing to share

store="$HOME/.claude/memory-stores/$(basename "$repo_root")"
[[ -d $store ]] || exit 0 # repo not opted in

link="$proj_dir/memory"
[[ -L $link ]] && exit 0                                    # already linked; idempotent
[[ -d $link ]] && { rmdir "$link" 2> /dev/null || exit 0; } # refuse to clobber a populated store

ln -s "$store" "$link" 2> /dev/null \
	|| printf '%s link failed: %s -> %s\n' "$(date -u +%FT%TZ || true)" "$link" "$store" \
		>> "$HOME/.claude/memory-stores/.link-failures.log"

exit 0
