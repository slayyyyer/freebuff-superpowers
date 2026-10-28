---
name: using-superpowers
description: Use at the start of any non-trivial request. Routes to the right workflow skill (brainstorming, planning, execution, TDD, debugging, review, verification) and enforces that a matching workflow is a mandate, not a suggestion.
license: MIT
metadata:
  category: meta
  pack: freebuff-superpowers
---

# Using Superpowers

## The rule

Before you answer, edit, or run anything, check the routing table. If a row matches, open
that skill's `SKILL.md` from this pack and follow it.

A matching skill is a mandate, not a suggestion. If you notice you are already writing
code when a skill says to plan first, stop and plan.

## Routing table

| Situation | Skill |
| --- | --- |
| Goal is vague, the request has several readings, or it is a new app/feature | `brainstorming` |
| Change spans more than one file, or more than one step, and the approach is settled | `writing-plans` |
| You have an approved plan and are about to change files | `executing-plans` |
| You are adding or changing observable behavior | `test-driven-development` |
| Something is broken, failing, or behaving inexplicably | `systematic-debugging` |
| The work looks finished and you are about to say so | `requesting-code-review` then `verification-before-completion` |
| You are writing or editing a skill | `writing-skills` |

## Order of operations

1. Understand the problem (`brainstorming`).
2. Agree the approach and the plan (`writing-plans`).
3. Execute one task at a time, verifying each (`executing-plans`, `test-driven-development`).
4. Diagnose surprises instead of patching them (`systematic-debugging`).
5. Review the diff, then prove it works (`requesting-code-review`, `verification-before-completion`).

## Proportionate process

This pack exists to stop careless work, not to turn a typo fix into a project kickoff.

- **One-line fix, obvious cause:** skip brainstorming and planning. Still verify.
- **Single clear task, 2-5 edits:** skip the design doc. Use `writing-plans` loosely as a
  checklist, then `executing-plans`.
- **Multiple readings of the goal, or a feature:** run the full order of operations.

When in doubt, ask one question rather than guessing and building the wrong thing.

## Freebuff specifics

You are running in Freebuff, which differs from Claude Code in ways that matter here:

- **Skills are files, not tools.** Read the `SKILL.md` with your file-reading tool when a
  skill is selected. The user can also force one with `/skill:name`.
- **No SessionStart hook.** The bootstrap that makes you check skills lives in the
  project's `AGENTS.md`. Re-read it after a context compaction; long sessions are where
  the bootstrap decays.
- **No general-purpose subagent dispatch.** You cannot hand a task to a fresh agent and
  review its work. Implement inline and execute the plan yourself. Specialized agents
  (file finding, research, browser) are for read-only investigation, not for edits.
- **You do have a todo list.** Use `write_todos` as the live plan. Mark each item
  complete as you finish it, before starting the next.
- **You do have structured questions.** Use `ask_questions` when a decision is genuinely
  the user's, and plain chat for everything else.

## Red flags

If you catch yourself doing any of these, stop and route:

- Writing implementation code before you can state the goal in one sentence.
- Making a second speculative fix to the same bug without a root-cause hypothesis.
- Saying "done" without naming the command that proved it.
- Expanding scope because the change was easy to make while you were there.
- Reading a skill and then following only the parts that suited you.
