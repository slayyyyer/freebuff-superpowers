---
name: systematic-debugging
description: Use when something is broken, failing, or behaving inexplicably. A four-phase root-cause process that forbids shotgun edits, requires evidence for each hypothesis, and ends with a regression test.
license: MIT
metadata:
  category: debugging
  pack: freebuff-superpowers
---

# Systematic Debugging

## The rule

Find the cause before changing the code. Two consecutive speculative fixes mean you are
guessing, and guessing is how a one-line bug becomes a five-file diff.

## Phase 1 — Reproduce

Get a reliable, minimal reproduction and capture it verbatim.

- The exact command, request, or interaction, and the full error text.
- The environment: branch, dependency versions, platform, relevant config.
- Whether it is deterministic, and what makes it appear or disappear.

If you cannot reproduce it, say so and gather evidence instead: logs, traces, the report
from the user with exact steps. Do not "fix" something you have not seen fail.

## Phase 2 — Narrow

Halve the search space rather than reading everything.

- Read the error bottom-up: the first frame in *your* code is usually the interesting one.
- Follow the data: where does the wrong value originate, and what is the last point it is
  known to be correct?
- Confirm assumptions with evidence, not intuition: add a log or assertion, write a
  focused test, or query the state. Delete the instrumentation afterwards.
- Check whether the code you are reading is the code that actually runs (build artifacts,
  stale `dist/`, cached modules, the wrong environment).

## Phase 3 — Root cause

State the cause in one sentence, and state the observation that would distinguish it from
the alternative explanations you considered.

> "The poller reads `status` before the transaction commits, so it sees the previous
> row. If that is right, delaying the read by one tick makes it pass, and reading a
> committed write always succeeds."

If you cannot state the cause, you are still in Phase 2. Keep investigating; do not start
editing.

## Phase 4 — Fix

1. Write a failing test that reproduces the bug. Watch it fail for the right reason.
2. Apply the smallest fix at the cause, not at the symptom. No defensive try/catch that
   hides the error; no retry that masks a race; no widened condition that silences a case.
3. Watch the test pass, then run the surrounding suite.
4. Grep for sibling call sites with the same bug and fix them deliberately, or report them.
5. Add the regression test permanently.

## Anti-patterns

- **Shotgun edits:** changing several things, then "it works now". You have learned
  nothing and shipped an unexplained diff.
- **Symptom patching:** suppressing the error message, adding a sleep, catching and
  ignoring, clamping a value until the crash stops.
- **Repeated re-runs:** running the same failing command without changing your mental
  model. Change what you know, not how many times you try.
- **Trusting green tests:** a suite that passes while the bug reproduces means the suite
  is wrong. Fix the test first.

## Stuck?

After two failed hypotheses, escalate deliberately: share the reproduction, what you ruled
out and how, and your current best theory. Ask for the one piece of information you cannot
get yourself. Silent flailing burns the user's tokens and their patience equally.
