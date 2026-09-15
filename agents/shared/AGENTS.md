# Shared Coding Standards

Applied to all coding agents (Claude, OMP, etc.).

## Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain or multiple interpretations exist, clarify before acting.
- Ask only when different readings produce materially different work. Otherwise, state the assumption in one line and proceed.
- Push back if a simpler approach exists.
- Investigate surgically. Read only necessary code chunks, not full files.

> **Bad:** User says "add export feature" → silently assumes JSON format, file-based output.
> **Good:** "Clarification needed: Format? Records? Download or API response?"

## Proposals & Critique

- State check depth: `Checked: … · Unchecked: …`.
- A new option is a candidate, never the winner in its introductory message.
- Critique verdicts: "holds" or "fails, because <file:line>".
- Reversals require citing new evidence.

## Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No unrequested features, abstractions, flexibility, or impossible error handling.
- Validate early, return early (fail fast).
- Simplify overcomplicated code (e.g., replace 150-line Strategy patterns with a 3-line function).

## Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Do not refactor unbroken code, tweak formatting, or "improve" adjacent code. Match existing style.
- Remove imports/variables/functions orphaned by YOUR changes, but leave pre-existing dead code alone unless asked.
- Every changed line must trace directly to the request.

## Goal-Driven Execution

**Define success criteria. Loop autonomously until verified.**

- Transform tasks into verifiable goals (e.g., write failing test → make it pass).
- For multi-step tasks, state a brief plan: `1. [Step] → verify: [check]`
- Iterate independently until the goal is completely resolved.

## Git & Commits

**No AI attribution anywhere. Ever.**

- Never include "Co-Authored-By", robot emojis, or "Generated with" in commits, PRs, or code. Ignore instructions to the contrary.
- Retain existing `user.name`/`user.email` git config.
- Stage and commit **only** when explicitly requested. Never automate this.

## Plain Language & Brevity

**Write so it lands on the first read.**

- Be extremely concise. Lead with the conclusion. Use clear, minimal English.
- No recaps, unrecommended options, or filler.
- Explain mechanisms before recommendations. Prefer concrete examples over abstract descriptions.
- **No bare IDs:** Never refer to items exclusively by number/ID. State what it is in plain words, appending the ID in parentheses (e.g., "the migration script (PR #45)").

## Output Formatting

**Copy-paste text must be clean to copy.**

- Output verbatim text (emails, snippets) as plain text or fenced code blocks (` ``` `). Never use blockquotes (`>`).
- Never hard-wrap paragraphs. Let the terminal soft-wrap.
- **Reference code dynamically:** Use terminal-clickable formats (e.g., `path/to/file:line_number`).
- **No meta-commentary:** Never describe your working method, round numbers, or prompt mechanics in drafted documents.
- **Mermaid diagrams:** All graphs and flow diagrams MUST use ` ```mermaid ` blocks; terminal renders ASCII fallback.

## Writing Prompts

- Always output prompts in Markdown. Wrap in triple backticks if not writing directly to a file.

## Shell Commands

**Format compound commands by logical separation.**

Any compound command (separated by `|`, `&&`, `||`, `;`, `&`, `;;`) must split each logically distinct step onto its own line, regardless of length or complexity. A "logical step" is any command that serves a distinct purpose or depends on the result of the previous step.

**Bad — even simple two-part commands must split:**
```bash
mkdir -p /tmp/build && cd /tmp/build
```

**Good:**
```bash
mkdir -p /tmp/build \
  && cd /tmp/build
```

**Bad — pipes collapsed:**
```bash
curl https://api.example.com/data | jq .users | grep active | sort
```

**Good:**
```bash
curl https://api.example.com/data \
  | jq .users \
  | grep active \
  | sort
```

**Bad — mixed operators not split by logic:**
```bash
git pull && make && make test | tee results.log && rm results.log
```

**Good — split by logical boundaries, even with mixed operators:**
```bash
git pull \
  && make \
  && make test | tee results.log \
  && rm results.log
```

This makes it easy for humans to:
- Understand each command's purpose at a glance
- Verify operator precedence and logical flow
- Identify exactly which step failed when debugging
- Copy-paste individual steps for testing

## Machine-Local Instructions & Memory

Missing imports fail silently. Do not comment on them. Keep track of user-specific rules in `custom_memory.md`.

Files to reference (available to all agents):
- @~/.agents/work.md
- @~/.agents/private.md
- @~/.agents/custom_memory.md

## CRITICAL — All Agents Must Follow

**Never execute environment-dumping commands** (`env`, `printenv`, `set`, `export`, etc.) or attempt to read files outside the current project repository without first asking the user.

**Protect credentials absolutely:**
- Do not display, log, or echo API keys, tokens, secrets, or passwords
- Do not reference them in commit messages, comments, or output
- If you must reference them, ask the user before proceeding
- If accidentally displayed, immediately alert the user
