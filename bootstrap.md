# Superpowers bootstrap

This is the block `install.mjs` writes into a project's `AGENTS.md`. It replaces the
`SessionStart` hook that Claude Code uses: without a hook, the only reliable way to make
an agent check skills at the start of a session is to say so in the instruction file it
reads on every turn.

The block is delimited by HTML comments so re-installing updates it in place instead of
appending a second copy.

```markdown
<!-- freebuff-superpowers:start -->
## Superpowers

This project uses the freebuff-superpowers workflow pack. Skills are mandatory
procedures, not suggestions.

Before a non-trivial task, read `<SKILLS_ROOT>/using-superpowers/SKILL.md` and follow the
skill it routes you to. The common ones:

- Goal is vague or the request has several readings → `<SKILLS_ROOT>/brainstorming/SKILL.md`
- Multi-step change with an agreed approach → `<SKILLS_ROOT>/writing-plans/SKILL.md`, then `<SKILLS_ROOT>/executing-plans/SKILL.md`
- Adding or changing observable behavior → `<SKILLS_ROOT>/test-driven-development/SKILL.md`
- Something is broken or inexplicable → `<SKILLS_ROOT>/systematic-debugging/SKILL.md`
- Before saying the work is done → `<SKILLS_ROOT>/requesting-code-review/SKILL.md`, then `<SKILLS_ROOT>/verification-before-completion/SKILL.md`
- Writing a new skill → `<SKILLS_ROOT>/writing-skills/SKILL.md`

Small fixes still get small process: skip brainstorming and planning, never skip
verification. If a long session has been compacted, re-read this block before continuing.
<!-- freebuff-superpowers:end -->
```

`<SKILLS_ROOT>` is replaced by the installer: `.agents/skills` for a project install, and
an absolute path under the home directory for a global install.
