---
name: wrap-it-up
description: Wraps up the current session and makes ready to close it down completely.
disable-model-invocation: true
---

# Wrap it up

Prepare to close out this session.

Check for any worktrees that can be exited and removed.
Do not leave any work orphaned; commits must have been pushed to a remote branch and if not, do so.
Not having at least one copy of completed work outside of this machine is considered a failure state.
If there is a compelling reason to leave the worktrees on disk beyond the life of this session, state why plainly.

Consider the memory files that are stored for any project(s) involved in this session, and see if any qualify to be promoted into the harness.
Session memories should only ever be promoted to the harness when they qualify as enduring guardrails with an expected lifespan beyond a single work item.
Their scope should be generalised wherever possible and reasonable; user-specific or machine-specific memories do not belong in multi-user/multi-repo spaces and should be excluded.

Summarise all work requested and achieved within the session.
If any work item management tickets were referenced or touched, include them in the summary.
