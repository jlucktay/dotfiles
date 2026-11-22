# Removing worktrees after a squash merge

I squash-merge almost everywhere, so a merged worktree branch's commits are never ancestors of the default branch.
`ExitWorktree` with `action: "remove"` always refuses such a worktree on its first call, reporting commits that would be discarded.
That refusal says nothing about whether work would be lost, so don't make a call you expect to be refused, and don't compare files to find out.

When I've asked for a worktree to be removed, check these first, running each as a separate plain command because compound commands can be refused inside a worktree:

1. `git status --short` prints nothing.
2. `git rev-parse HEAD` gives the worktree's final commit.
3. `gh pr list --head <branch> --state merged --json number,headRefOid,mergeCommit` returns a PR whose `headRefOid` equals that commit.
  Add `--repo <owner>/<repo>` if the current directory doesn't identify the repository.

If all three hold, the merged PR contains everything committed in the worktree, so call `ExitWorktree` once with `action: "remove"` and `discard_changes: true`.
My request to remove the worktree plus these checks counts as the confirmation the tool asks for, so don't ask me again.
Afterwards, report the PR number and merge commit.

If any check fails, stop and tell me what doesn't match instead of using `discard_changes`: uncommitted files, commits made after the PR's final commit, or no merged PR.
A rebase merge or other project-specific flow also lands here, so check with me rather than working around it.

## Beyond the worktree's own branch

- `ExitWorktree` only removes the worktree the session is in and created itself. For one left behind by a later switch, or entered with `path`, exit with `action: "keep"` and, once the checks above pass, remove it from the main checkout with `git worktree remove <path>`.
- `ExitWorktree` deletes only the branch it created. Other branches made in the worktree, such as one `gh stack` layer per pull request, stay behind: check each tip against its own merged PR's `headRefOid` as above, then delete them with `git branch --delete --force`.
- `gh stack` keeps its catalog in the shared Git directory. Before deleting a merged stack's branches, run `gh stack unstack --local` with one of them checked out; never without `--local`, which unstacks it on GitHub. A stack adopted with `gh stack init` and linked with `gh stack link` isn't tracked under its GitHub number, so `gh stack unstack --local <number>` reports it as untracked.

This doesn't authorise removing a worktree I haven't asked to remove, or one that's locked or belongs to another session.
