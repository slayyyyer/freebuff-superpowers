---
name: executing-plans
description: Use when a plan is approved and you are about to change files. Executes one task at a time with verification between tasks, keeps the todo list honest, and stops rather than improvising when reality diverges from the plan.
license: MIT
metadata:
  category: collaboration
  pack: freebuff-superpowers
---

# Executing Plans

## The rule

One task at a time, verified before the next. A plan you silently abandon is worse than
no plan, because the user is still reading the old one.

## Freebuff reality

Claude Code's Superpowers dispatches a fresh subagent per task and reviews its output.
Freebuff does not expose general-purpose subagents, so **you execute the plan inline**.
That changes the failure modes: context fills up, you get bored of verification, and you
start batching tasks. Watch for exactly those.

## Steps

### 1. Load the plan into the todo list

Create one `write_todos` item per plan task, in order, each named after the task's
verification. The user watches this list as your progress.

### 2. Before each task

Re-read that task only. Open the files it names. If the plan's premise is already false
(the function exists, the file moved, the API differs), stop and revise the plan rather
than improvising around it.

### 3. Do the task

Follow `test-driven-development` where behavior changes. Keep the diff to what the task
describes. If you notice an unrelated problem, note it; do not fix it.

### 4. Verify, then mark complete

Run the task's verification command and inspect the output. Then mark the todo complete,
before starting the next one. Never mark a batch complete at the end.

### 5. Report in one or two lines

After each task, a brief note: what changed, what proved it, what is next. This is where
the user catches a wrong turn while it is still cheap.

## When reality diverges

Divergence is normal; silence is not. When the plan is wrong:

1. Stop the current task.
2. Say what you found, in one sentence.
3. Propose the smallest plan change that unblocks it.
4. Continue if the change is obvious and reversible; ask if it changes scope, interfaces,
   data, or anything the user already approved.

## Context discipline

- Batch independent reads and searches; never re-read a file you have not changed.
- Quote only the lines you need from large files.
- Re-read `AGENTS.md` and the plan after a compaction; that is when plans get forgotten.
- If the task list is long, summarize completed tasks in one line each and move on.

## Red flags

- You are on task 5 and have not run a single verification command.
- The todo list says three items; your diff touches six files.
- You are fixing something that was not in the plan because it was "right there".
- You hit the same failure twice. That is `systematic-debugging`, not a third attempt.
- You are about to say "the remaining tasks are straightforward" and skip them.
