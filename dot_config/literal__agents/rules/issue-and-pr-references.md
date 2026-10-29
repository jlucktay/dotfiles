# Issue and pull request references

GitHub numbers issues and pull requests from one shared sequence and writes both as `#<number>`, so a bare `#61` doesn't say which kind it is.
When I read terminal output, I need to tell them apart at a glance.

## In terminal output

- Never write a bare `#<number>`. Always put the kind in front: `issue #12`, `PR #61`.
- Start a sentence with `Issue #12` or `PR #61`; never use `pull #61`, `pull request #61` or `MR #61` as alternatives, so the spelling stays the same everywhere.
- When the URL is known, make the whole label the link text: `[issue #12](https://github.com/<owner>/<repo>/issues/12)`, `[PR #61](https://github.com/<owner>/<repo>/pull/61)`.
- In tables and lists that mix the two, either give the kind its own column or keep the prefix in every cell; don't rely on a heading to carry it.
- A squash-merge suffix in a commit subject, such as `(#61)`, is a pull request: call it `PR #61` when discussing it.
- References to another repository keep the prefix too: `issue tj-farm/monorepo#12`, `PR tj-farm/monorepo#61`.

## Not in text bound for GitHub

This rule only governs what's printed in the terminal.
Text that GitHub renders (commit messages, issue and PR bodies, comments) keeps GitHub's own syntax, because `#<number>` autolinking and closing keywords such as `Closes #N` and `Part of #N` only work in that exact form.
