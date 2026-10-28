# freebuff-superpowers

A Claude Code "superpowers"-style workflow pack for **Freebuff**, built out of the
mechanism Freebuff actually supports: portable `SKILL.md` skills plus an `AGENTS.md`
bootstrap. No plugin system, no hooks, no marketplace required.

Installable with `npx skills add slayyyyer/freebuff-superpowers`.

## Why this exists

[Superpowers](https://github.com/obra/superpowers) is a plugin that gives Claude Code a
software development methodology: brainstorm before building, plan in small tasks, real
RED-GREEN-REFACTOR, systematic debugging, review before declaring done. It ships as a
Claude Code plugin, and Freebuff has no plugin system — there is an open upstream
[tracking issue](https://github.com/obra/superpowers/issues/2168) for Freebuff support
that is still unmerged.

Freebuff does have skills. It scans `.agents/skills/`, `.claude/skills/`,
`~/.agents/skills/` and `~/.claude/skills/` for `SKILL.md` folders, exposes each as
`/skill:name`, and lets the agent load one when it decides the skill is relevant.

That covers the *mechanism*. What it does not cover is the part Superpowers gets from
being a plugin:

| Claude Code superpowers | Freebuff reality | What this pack does |
| --- | --- | --- |
| `SessionStart` hook injects the bootstrap every session | No hooks | A marked block in `AGENTS.md` that the agent reads each turn |
| Skills auto-trigger via the plugin's tool integration | Skills load on demand | `using-superpowers` routes explicitly, and the `AGENTS.md` block lists the paths |
| `subagent-driven-development` dispatches a fresh agent per task | No general-purpose subagents | `executing-plans` runs inline against the todo list instead |
| `using-git-worktrees` isolates branches | Freebuff Desktop already isolates parallel agents | Omitted; use git yourself in the CLI |
| Plugin marketplace install | No marketplace | `install.sh` / `install.ps1`, or copy two things by hand |

## Install

**From GitHub, with the skills CLI** (Node 22.20+):

```bash
npx skills add slayyyyer/freebuff-superpowers -a claude-code --skill '*' --yes --copy -g
```

**Installing on Freebuff:** the CLI has no Freebuff entry, and `--agent universal` looks
like the safe choice but is not one — its global path is `~/.config/agents/skills/`, which
Freebuff never scans. Use `-a claude-code` instead: it resolves to `~/.claude/skills/`
globally and `.claude/skills/` in a project, both of which Freebuff reads. `-a codex` and
`-a cline` also work globally, via `~/.agents/skills/`.

`-g` installs into `~/.claude/skills` so every project can use the skills. Omit it to
install into the current project only (`.claude/skills`). Start a new Freebuff session
afterwards and check `/skill:brainstorming`.

The CLI copies skills but does not write the `AGENTS.md` block, so for the automatic
bootstrap run the installer after cloning (below) or paste
[bootstrap.md](bootstrap.md) into your project's `AGENTS.md` yourself.

**From a local clone — Windows (PowerShell 5.1+):**

```powershell
.\install.ps1                 # project: .\.agents\skills + .\AGENTS.md
.\install.ps1 -Global         # skills to ~\.agents\skills, block still in the project
.\install.ps1 -DryRun         # show what would change
.\install.ps1 -Force          # replace existing skills
```

**macOS / Linux / Git Bash:**

```bash
./install.sh                  # project: ./.agents/skills + ./AGENTS.md
./install.sh --global         # skills to ~/.agents/skills
./install.sh --dry-run
./install.sh --force
```

Both installers copy the skills and then add or update one marked block in the project's
`AGENTS.md`, leaving the rest of that file alone. Re-running is safe: existing skill
folders are kept unless you pass `--force` / `-Force`, and the block is replaced in place
rather than appended twice.

**Manual install** (no shell needed):

1. Copy the skill folders into `.agents/skills/`:
   `brainstorming/`, `executing-plans/`, `requesting-code-review/`,
   `systematic-debugging/`, `test-driven-development/`, `using-superpowers/`,
   `verification-before-completion/`, `writing-plans/`, `writing-skills/`.
2. Paste the block from [bootstrap.md](bootstrap.md) at the end of your project's
   `AGENTS.md`, replacing `<SKILLS_ROOT>` with `.agents/skills`.

Then start a new Freebuff session. Check that it loaded with `/skill:brainstorming`.

> **Freebuff Desktop:** account skills are synced from Cloud, so a project folder is not
> automatically in your account library. The `AGENTS.md` block still works from inside the
> project because it points at files by path. If your build offers an import for account
> skills, the same folders are valid there unchanged.

## What's in the pack

| Skill | Triggers on | What it enforces |
| --- | --- | --- |
| `using-superpowers` | Start of any non-trivial request | Routes to the right skill; a matching workflow is a mandate |
| `brainstorming` | Vague goal, several readings, new feature | One question at a time, playback of intent, design approval before code |
| `writing-plans` | Agreed approach, more than a couple of steps | 2-5 minute tasks with exact files and a check that can fail |
| `executing-plans` | Plan approved, about to edit | One task at a time, verify between tasks, stop when reality diverges |
| `test-driven-development` | Any new or changed behavior | RED-GREEN-REFACTOR with real runs; delete code written before its test |
| `systematic-debugging` | Broken, failing, inexplicable | Reproduce, narrow, name one root cause, fix with a regression test |
| `requesting-code-review` | Before saying done | Review your own diff by severity; criticals block completion |
| `verification-before-completion` | Before claiming success | Evidence per claim, re-run after the last edit, report what failed |
| `writing-skills` | Authoring or editing a skill | Frontmatter rules, trigger-shaped descriptions, test it in a fresh session |

The pack is deliberately small and proportionate: `using-superpowers` says to skip
brainstorming and planning for a one-line fix. Process that fires on every trivial task is
worse than no process.

## Validate a change

```bash
bash scripts/validate.sh
```

Checks every skill's frontmatter and name against Freebuff's rules (invalid skills are
rejected silently), and checks that `bootstrap.md` actually routes to every skill in the
pack. Run it after adding or renaming anything.

## Adding your own skill

1. Create `skills/<name>/SKILL.md` with `name`, `description`, `license`, `metadata`.
2. The directory name and the frontmatter `name` must match exactly, lowercase with single
   hyphens.
3. Write the description as a trigger ("Use when ..."), not a table of contents. It is the
   only text the agent sees before deciding to load the file.
4. Add a line for it to the block in [bootstrap.md](bootstrap.md), or it will never be
   found.
5. Run `bash scripts/validate.sh`, reinstall, then test it in a fresh session.

See [`skills/writing-skills/SKILL.md`](skills/writing-skills/SKILL.md) for the full guide.

## Using upstream Superpowers instead

You can. Its skills are plain Markdown and Freebuff loads them:

```bash
npx skills add obra/superpowers --agent universal --skill '*' --yes --copy
```

The catch is the one this pack exists to solve: without a bootstrap the agent has no
reason to check skills at the start of a session, and several skills assume features
Freebuff lacks (subagent dispatch, hooks, worktree automation). If you go that route, add
a pointer in `AGENTS.md` and expect the execution skills to need adapting.

## Credit

The methodology and skill taxonomy are Jesse Vincent's
([obra/superpowers](https://github.com/obra/superpowers), MIT). This is not a fork and
contains no copied skill text: it is an independent, Freebuff-specific implementation of
the same ideas, sized for a harness without plugins, hooks, or general-purpose subagents.

MIT.
