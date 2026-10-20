# Code comments

- Comments are rare, one line, and only for constraints the code can't express.
- Never write comments that reference this conversation, a bug I mentioned, or why a change was made — that context belongs in the chat or commit message, not the code.
- Never write comments that are only temporally useful: setup prerequisites, missing permissions or entitlements, rollout sequencing. Once the system reaches steady state they are noise.
- Test: would this comment make sense to someone who never saw this session? If not, delete it.
- Test: will this comment still be useful once everything is provisioned and working? If it only helped during a transition window, delete it.
