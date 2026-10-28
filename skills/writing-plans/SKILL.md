---
name: writing-plans
description: Use when the approach is agreed and the change takes more than a couple of steps. Breaks the work into small, independently verifiable tasks with exact files and verification commands, so execution needs no guesswork.
license: MIT
metadata:
  category: collaboration
  pack: freebuff-superpowers
---

# Writing Plans

## The rule

Write the plan for someone with no project context, no judgement, and no memory of this
conversation. If a task in the plan needs a decision to be made while executing it, the
plan is not finished.

## Input

An agreed approach. If the goal is still ambiguous, go back to `brainstorming`.

## Output

A plan file at `docs/plans/YYYY-MM-DD-<slug>.md`, plus one `write_todos` entry per task.

```markdown
# <Feature> implementation plan

Goal: <one sentence>
Design: <link to the spec, if one exists>

## Task 1 — <verb-first name>
Files: src/thing.ts (add `parseThing`), src/thing.test.ts (new)
Change: <exactly what to do, with the intended signatures or behavior>
Verify: `bun test src/thing.test.ts` → the new case passes, the old cases still pass
Done when: <observable condition>

## Task 2 — ...
```

## Task rules

- **2 to 5 minutes each.** If a task needs a paragraph to explain, split it.
- **Verb first, specific.** "Add retry with backoff to the deploy poller", not "improve
  reliability".
- **Name the files.** Real paths, created or modified. Unknown paths are a research task,
  not an implementation task.
- **Name the verification.** A command with expected output, a request with expected
  response, or a DOM assertion. "Check it works" is not verification.
- **One purpose per task.** Never combine "refactor X and add feature Y".
- **Order for feedback.** The riskiest or most uncertain task goes first, while changing
  course is cheap. Failing test before implementation. Shared plumbing before features.
- **Include cleanup.** The last tasks are: full test run, self-review of the diff, update
  docs if behavior changed.
- **No hidden scope.** Anything you would like to do but nobody asked for is listed under
  "Not doing" at the bottom of the plan.

## Verifying the plan before you hand it over

Read it back as the executor:

1. Could two people follow this and produce the same change? If not, add detail.
2. Does every task have a check that could fail? If not, add one.
3. Is any task secretly two tasks? Split it.
4. Is there a task whose failure has no defined response? Add the fallback.

Then get explicit approval if the user has not already seen the plan. Keep the approval
short: number of tasks, the risky one, and what is explicitly out of scope.

## Red flags

- A task that says "make it work", "handle edge cases", or "wire it up".
- More than ~12 tasks with no milestones — the plan is too big to review, so slice the
  feature instead.
- Verification that restates the change ("add function X, verify X exists") instead of
  testing behavior.
- Planning around a file you have never opened.
