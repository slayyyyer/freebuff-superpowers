---
name: brainstorming
description: Use before building anything non-trivial, when the goal is vague or has several reasonable readings. Draws out intent through short questions, plays the understanding back, and produces an agreed design before code is written.
license: MIT
metadata:
  category: collaboration
  pack: freebuff-superpowers
---

# Brainstorming

## The rule

Do not write implementation code until the problem is agreed in writing. The most
expensive failure is a correct implementation of the wrong thing.

## Steps

### 1. Read before asking

Read enough of the project to answer your own questions: existing conventions, the files
involved, the test setup, any `AGENTS.md` or README. Never ask the user something the
repository already says.

### 2. Ask one question at a time

Ask only questions whose answers change what you build. Prefer `ask_questions` with two
to four concrete options when the choice is discrete; use plain chat for open questions.

Good questions:

- Who uses this, and what do they do today instead?
- What must be true for this to count as working?
- Is anything explicitly out of scope?
- Which of these approaches fits your constraints: [A], [B], or neither?

Bad questions: anything answered by reading the code; anything about details you can
decide sensibly and note later; long question walls that make the user do your job.

### 3. Play it back

Restate, in your own words, in five lines or fewer:

- **Goal** — the outcome, in one sentence.
- **Constraints** — stack, compatibility, performance, deadlines that were stated.
- **Non-goals** — what you are deliberately not doing.
- **Success** — how the user will know it works.

Invite correction. People catch misunderstandings in a restatement that they miss in a
question.

### 4. Right-size the artifact

- **Small change:** the playback in chat is the design. Do not create a document.
- **Feature or project:** write `docs/specs/YYYY-MM-DD-<slug>-design.md` with `Problem`,
  `Goals`, `Non-goals`, `Approach`, `Changes` (files, APIs, schema), `Risks`,
  `Test plan`, `Open questions`.

Propose the smallest version that meets the goal. When reasonable versions differ in size
or direction, say so explicitly and let the user pick. Do not quietly build the largest
one you can imagine.

### 5. Stop at the approval gate

End with: "Approve this and I'll write the implementation plan." Do not slide from design
into implementation in the same breath.

## Red flags

- You have written a file before the user agreed what they wanted.
- You asked six questions when two would have decided it.
- The design lists features nobody asked for.
- You are designing around a constraint you assumed instead of one you read.
- The user says "just do it" — then state your assumptions in two lines and proceed.
