---
name: requesting-code-review
description: Use before declaring work finished. A severity-ranked self-review of your own diff against the request, covering correctness, tests, error handling, security, performance, and unrequested changes.
license: MIT
metadata:
  category: quality
  pack: freebuff-superpowers
---

# Requesting Code Review

## The rule

Review your own diff before anyone else has to. Not the code you remember writing — the
diff you actually produced.

## Steps

### 1. Get the diff

`git diff` for unstaged work, `git diff --staged` for staged, `git diff main...HEAD` for a
branch. Read it top to bottom as if a colleague wrote it and you are deciding whether to
approve.

### 2. Review against the request, not against your intentions

Answer these explicitly:

- **Correctness** — Does it do what was asked, including the edge cases the request named?
  What happens on empty input, missing keys, null, zero, duplicate calls, concurrent calls?
- **Tests** — Is there a test that fails if this breaks? Did you see it fail first? Does the
  suite still pass?
- **Errors** — Are failures surfaced with enough context to debug? Does anything swallow an
  error, catch broadly, or retry forever?
- **Security** — Any secret, token, or credential in code, logs, or commits? Any user input
  reaching a shell, SQL string, HTML, or file path unvalidated? Any widened permission?
- **Performance** — Anything quadratic, N+1, unbounded, or synchronous in a hot path?
- **Surface area** — Any change the user did not ask for: renamed exports, reformatted
  files, new dependencies, refactors, "improvements"?
- **Residue** — Debug logs, commented-out code, TODOs, placeholder text, temp files,
  skipped tests, suppressed lint/type errors?

### 3. Report by severity

Classify what you find, with file and line:

- **Critical** — wrong behavior, data loss, security hole, broken build. Blocks completion;
  fix it now.
- **Major** — missing test coverage for the change, unclear failure mode, fragile edge case.
  Fix or explicitly raise it.
- **Minor** — naming, duplication, small readability. Fix if cheap; otherwise mention it.

Include what you checked and found clean. "No issues" is only credible with the list.

### 4. Separate your diff from other people's

If the working tree contains changes you did not make, do not review, reformat, or revert
them. Call them out as untouched and review only your own hunks.

## Optional: independent review

If the environment offers a read-only reviewer or research agent, hand it the diff and the
original request, and ask for issues by severity. Treat its output as a checklist to
verify, not as findings to paste: an agent that cannot run the code invents plausible
problems.

## Red flags

- Reviewing after the user asks "is this right?" — the review was due before that.
- "LGTM" with no list of what you checked.
- Fixing a minor style issue while leaving a critical correctness bug noted but unfixed.
- Silencing a check (type, lint, test) to make the review pass.
