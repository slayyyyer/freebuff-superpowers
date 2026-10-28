---
name: test-driven-development
description: Use whenever you add or change observable behavior. Enforces RED-GREEN-REFACTOR with real test runs, forbids production code written before a failing test, and requires tests that actually fail when the implementation breaks.
license: MIT
metadata:
  category: testing
  pack: freebuff-superpowers
---

# Test-Driven Development

## The rule

No production code without a failing test for it. If you already wrote the code, delete
it or park it, write the test, and let the failure drive the implementation back.

This is not a style preference. A test you never saw fail is a test you do not know can
fail.

## The cycle

### RED

Write the smallest test that expresses one behavior, through the interface a user of the
code will actually use. Run it.

- Confirm it fails **for the intended reason**. A syntax error, an import error, or a typo
  is not a red test; fix it and run again.
- Read the failure message. It should describe the missing behavior, not the broken test.

### GREEN

Write the minimal implementation that makes it pass. Run the test.

- Then run the surrounding suite, not just the new case.
- Resist generalizing. Duplication in the second case is cheaper than the wrong
  abstraction in the first.

### REFACTOR

With tests green, remove duplication and improve names. Re-run after each refactor step.
Never refactor and change behavior in the same step.

## Test quality rules

- **Behavior, not implementation.** Assert on returned values, rendered output, HTTP
  responses, observable side effects. A test that breaks when you rename a private
  function is a liability.
- **One behavior per test**, with a name that states the behavior.
- **No weakened assertions to get green.** No `toBeTruthy` where `toEqual` belongs, no
  widened types, no `any`, no skipped tests, no `assert` deleted to make a suite pass.
- **Prove the test can fail.** Temporarily break the implementation (or reason precisely
  about it) and confirm the test catches it. If it does not, the test is decoration.
- **Deterministic.** No sleeps for timing; no dependence on network, clock, or test order.
  If you must control time or a random source, inject it.

## Running tests in Freebuff

- Use the project's real command from `package.json`, `Makefile`, `pyproject.toml`, or CI
  config. Do not invent one.
- Keep the exit status. If you pipe output through `head`, `tail`, or `grep`, use
  `set -o pipefail` so a failure cannot be masked by a successful pipe.
- Read the failure output yourself. A red suite you did not read is not information.
- Re-run the affected tests after every edit. An earlier green run does not cover a later
  change.

## When TDD does not fit

Visual layout, exploratory spikes, generated code, and one-off config are legitimate
exceptions. Say so explicitly, and substitute a concrete check:

- UI: assert on DOM structure, accessible roles, and text through a test, not a
  screenshot you did not look at.
- Spike: time-box it, throw it away, then write the real change test-first.
- Config: validate by parsing it and asserting the resulting behavior.

"The test would be annoying to write" is not an exception.
