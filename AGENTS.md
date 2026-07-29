# Global Ground Rules

The following rules apply to all interactions, workspaces, and projects across this machine. They govern the behaviour of the AI assistant to ensure high-quality, safe, and consistent results.

---

## 1. Safety & Execution

- **Never perform destructive actions** (e.g., `rm -rf`, dropping databases, force pushing to main) without explicitly asking for permission first.
- **Double-check paths** before writing or overwriting files to avoid accidental data loss.
- **Confirm before committing** and do not automatically create pull requests without explicit confirmation.
  - Never push commits or open PRs unless explicitly asked. For local script edits, keep changes on disk and do not create worktrees or draft PRs unprompted.
  - All PR/branch work must happen in an isolated worktree, and worktrees must be cleaned up after the task completes.
  - Commits should be grouped logically per change — confirm grouping before committing.
- Merges blocked by required-review policy may only be overridden with `--admin` after explicit user confirmation.

## 2. Communication Style

- **No sycophancy**: I am not interested in unnecessary pleasantries of any kind.
- **Explain the "Why"**: When proposing a design change or fixing a bug, briefly explain the reasoning behind the solution.
- **Admit uncertainty**: If you are unsure about the user's intent or missing context, ask clarifying questions instead of guessing.

## 3. Code Quality & Formatting

- **Read before writing**: Always use tools to read existing code context and project structures before generating new code.
- **Keep it idiomatic**: Follow the standard idioms and conventions of the language being used (e.g., idiomatic Go, standard Python PEPs).
- **No silent breakages**: Preserve existing comments and docstrings. Do not remove unrelated code while refactoring unless explicitly instructed.
- **Don't leave placeholders**: Write complete code blocks instead of using `// ... rest of the code ...` comments unless it's a very large file, and we are doing an isolated edit.

## 4. Problem-Solving & Planning

- **Step-by-step**: For complex tasks, break the problem down into smaller steps and confirm the plan before executing massive changes.
- **Verify**: After writing tests or fixing bugs, run the test suite or verify the fix locally if the environment permits it.

## 5. User Context

- I am a platform engineer.
- I want results with explanations and context.
- For all command line queries provided, use the long form of flags wherever possible or available.
- If a tool isn't installed and there is no network access to perform an installation, I don't need to hear about it, just move on with the material that is available.
- When I ask about the `yq` command, I am referring to the Go binary from `mikefarah`, and not any other variant.
- Do not mix up `yq` with `jq`, and do not try to use `jq` keywords and syntax in `yq` pipelines and vice versa.

## 6. Formatting Constraints

- **NO LINE WRAPPING**: Never wrap long lines or columns in code, comments, prose, or anywhere, in any file format. There are no line length limits.
- Respect the line-wrapping/column style directive: do not column-wrap comments or Taskfile cmd blocks at ~80 chars.
  - Leave folded block scalars with strip chomping indicators (`>-`) in YAML alone; their multiline strings are written that way in the first instance for the sake of readability.

## 7. Go Preferences

- **Testing**: Always use `github.com/matryer/is` and strictly adhere to table-driven tests.
- **CLI**: Use `github.com/urfave/cli` for building command-line tools.

## 8. Internal Agent Rules

- **`ask_question` Tool Usage**: Never add manual "Other" or "Something else" options when using the `ask_question` tool.

## 9. Go Workspaces in Sandbox

- When executing `go` commands (like `go get`, `go test`, `go mod tidy`) within a specific module directory, if permission to the parent directory containing `go.work` is
restricted, automatically prefix the commands with `GOWORK=off` to isolate execution to the local `go.mod`, avoiding unnecessary permission blocks.

## 10. Comprehensive Requirements Checklist

- Before writing code for a new tool or feature, explicitly list out and cross-reference all project-specific instructions (e.g., `AGENTS.md`) alongside Global Ground
Rules (like Go Preferences) in the thought process to ensure zero missed constraints.

## 11. Scripting Conventions

- Use `jq` (not Python) for JSON parsing and validation.
- Use `set -u`-safe idioms in all shell scripts (guard against empty arrays).
