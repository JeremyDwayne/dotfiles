---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. Claude Code writes it to `~/.claude/projects/<slug>/<session-uuid>.jsonl`, where `<slug>` is the absolute cwd with every `/` and `.` replaced by `-` (`/Users/me/.dotfiles` becomes `-Users-me--dotfiles`). Derive the slug from the cwd and use that folder. Do not glob across `~/.claude/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
ls -t ~/.claude/projects/<slug>/*.jsonl ~/.claude/projects/<slug>/*/subagents/*.jsonl 2>/dev/null | head -10
```

Two transcript layouts: session (`<session-uuid>.jsonl`) and subagent (`<session-uuid>/subagents/agent-<id>.jsonl`).

For each candidate, check that one of its `"type":"user"` lines holds the conversation's opening user prompt, for example with `grep -lF '<a distinctive phrase from that prompt>'`. Take the matching path. If no path resolves, write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three Agent calls, `subagent_type: "general-purpose"`, with `model` set as below. `general-purpose` keeps MCP access, which reviewers need for context lookups (tickets, chat threads, observability traces referenced in the transcript).

Each reviewer and the synthesizer name a role line in `${CLAUDE_PLUGIN_ROOT}/models.md`. Set `model` to that line's value, and omit `model` when the value is `inherit`.

| Lens | Role line | Prompt template |
|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `references/divergent-reviewer.md` |

Paste each template verbatim into its brief, substituting the transcript path or digest where marked. Reviewers return findings in the Agent result.

### 3. Synthesize

One Agent call, `subagent_type: "general-purpose"`, with `model` from the `reflect judgment, divergent, synthesizer` line. The synthesizer's quality check includes spot-verifying citations, which can require MCP access, and `general-purpose` keeps it. Paste `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the **encode-lessons-in-structure** principle at `${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure.md`.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): load the `writing-for-agents` skill with the Skill tool and draft, test, and iterate the edit under it. When `writing-for-agents` is not installed, use `anthropic-skills:skill-creator`.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `writing-for-agents` and rewrite the description so it triggers on the missed case.
- `new skill via writing-for-agents: <kebab-name>`: hand creation to `writing-for-agents`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
