---
name: writing-skills
description: Use when creating or editing a skill in this pack. Covers frontmatter rules, writing a description that actually triggers, structuring the body, and testing whether a fresh session follows it.
license: MIT
metadata:
  category: meta
  pack: freebuff-superpowers
---

# Writing Skills

## The rule

A skill is a procedure, not documentation. If it does not change what the agent does on a
specific kind of request, it does not belong in the pack.

## Format

```
skills/<name>/SKILL.md
```

```markdown
---
name: <matches the directory exactly>
description: <when to use it, and what it produces — 1 to 1024 characters>
license: MIT
metadata:
  category: <meta|collaboration|testing|quality|debugging>
  pack: freebuff-superpowers
---

# Title

## The rule
## Steps
## Red flags
```

Validation rules for `name`: lowercase letters, digits, and single hyphens; 1-64
characters; no leading, trailing, or doubled hyphens; identical to the directory name.
Freebuff rejects violations silently, so a bad name means a skill that never loads.

## The description is the product

The description is the only text the agent sees before loading the skill. It must say
when to use it, not merely what is inside.

- Good: "Use when a dependency upgrade breaks the build. Finds the breaking change,
  pins or adapts, and proves it with the project's check command."
- Bad: "Notes about dependencies."

Include the situation, the situation's synonyms a user might type, and the outcome.

## Body

1. **Rule first.** One paragraph the agent cannot misread. State the thing it is tempted
   to do and forbid it.
2. **Steps, numbered.** Concrete commands and decision points, not principles.
3. **Adapt to the harness.** Almost every Claude Code skill assumes hooks, subagent
   dispatch, or a plugin marketplace. Say explicitly what to do instead in Freebuff.
4. **Red flags.** The specific ways an agent will rationalise ignoring the skill. This
   section does the most work per line.
5. **Under ~200 lines.** A skill competes for context with everything else. If it is
   longer, split it or move reference material into a sibling file the skill points to.

Do not restate other skills. Point at them by name.

## Test it

A skill is untested code. Before you call it done:

1. Start a fresh session with no memory of writing it.
2. Give a realistic prompt that should trigger it, with no mention of the skill's name.
3. Check two things: was it loaded, and was it followed — including the inconvenient
   steps. An agent that reads a skill and does the easy half has not passed.
4. Run a second prompt that should *not* trigger it. Over-triggering is worse than not
   having the skill, because it makes every task slower.

Record what happened. "Seems clear" is not a test.

## Editing an existing skill

- Change the smallest part that fixes the observed failure. A skill that stops
  over-triggering by becoming vague has traded one failure for a worse one.
- Keep the rule and the red flags in sync; half-updated skills are how agents learn to
  ignore both.
- Bump nothing, tag nothing, and do not reformat the rest of the file.
