---
name: ovo-open-prs
description: Lists all PRs authored by me currently open in the OVO Tech org.
disable-model-invocation: true
---

# OVO Open PRs

This skill is not scoped to any particular repo or project; it is across the entire `ovotech` GitHub organisation.

Query the GitHub API for pull requests, with the following filters/fields:

- Authored by me: `author:@me`
- Inside the OVO Tech org: `org:ovotech`
- In draft (grey) or open (green) state, not closed (red)/merged (purple)/archived

Show full URL links to each PR, along with:

- CI status
- Whether the PR has any merge conflicts
- Review status

Also flag if any PR does not have any assigned reviewers.
These should have been set manually, or automatically via a mechanism such as CODEOWNERS.
