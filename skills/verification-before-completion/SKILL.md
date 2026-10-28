---
name: verification-before-completion
description: Use before saying anything is done or fixed. Defines what counts as evidence, requires re-running checks after the final edit, and forbids claiming a check you did not run.
license: MIT
metadata:
  category: quality
  pack: freebuff-superpowers
---

# Verification Before Completion

## The rule

Done means you ran the thing and read the result. Not "should work", not "the code looks
right", not "the tests passed earlier".

## What counts as evidence

For each claim, there must be a command, request, or interaction whose output you
inspected:

| Claim | Evidence |
| --- | --- |
| Tests pass | The test command's exit status 0 and its summary line |
| Build works | The build command completes, artifacts exist where expected |
| Bug is fixed | The reproduction no longer reproduces, and a regression test covers it |
| Feature works | The behavior exercised the way the user will use it: request/response, CLI run, DOM state |
| Types are sound | The project's typecheck command, not an editor squiggle |
| Data changed correctly | The actual read-back, not the write's HTTP 200 |

A green exit code alone is not evidence that the feature works. Exercise it.

## Steps

1. **Re-run after the last edit.** An earlier pass does not cover a later change. If you
   touched the code after verifying, verify again.
2. **Exercise the delivered behavior.** Drive the app the way the user will: send the
   request, run the CLI, click through the route, assert on the DOM. Inspect the response,
   not just the status.
3. **Preserve exit status in pipelines.** Use `set -o pipefail`, or capture `$?`, whenever
   you filter output through `head`, `tail`, `grep`, or `jq`.
4. **Read the failure, do not summarise past it.** If a check fails, that is the finding.
5. **Account for every check you claimed.** If you listed a check and did not run it, say
   so plainly.

## Reporting

End with a short, specific statement:

- What changed, in one or two lines per area.
- What you ran to prove it: exact commands and what they output.
- What failed, or could not run, and why. A blocked check reported honestly is fine; a
  blocked check reported as a pass is not.
- What the user must still do: credentials, a migration, a manual review, a deploy.

## Red flags

- "All tests pass" with no test command in the transcript.
- "The build is clean" when the build was never run after the last edit.
- A failing check explained away as flaky without evidence.
- Weakening an assertion, skipping a test, or adding a suppression to reach green.
- Editing files after the final verification and not re-running anything.
- Claiming a UI change is correct without exercising it, or a performance win without a
  measurement.
