#!/usr/bin/env bash
# freebuff-superpowers installer.
#
# Copies the skills into .agents/skills (or ~/.agents/skills) and writes the bootstrap
# block into the project's AGENTS.md, replacing it in place on later runs.
set -euo pipefail

START_MARKER='<!-- freebuff-superpowers:start -->'
END_MARKER='<!-- freebuff-superpowers:end -->'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS="$SCRIPT_DIR/skills"
SOURCE_BOOTSTRAP="$SCRIPT_DIR/bootstrap.md"

GLOBAL=0
PROJECT_ROOT="$PWD"
DO_BOOTSTRAP=1
FORCE=0
DRY_RUN=0

die() {
  printf '\nerror: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
freebuff-superpowers

Usage:
  ./install.sh [options]

Options:
  -g, --global     Install skills to ~/.agents/skills instead of ./.agents/skills
      --dir <path> Project root to install into (default: current directory)
      --no-bootstrap
                   Copy skills only; do not touch AGENTS.md
  -f, --force      Overwrite skill directories that already exist
      --dry-run    Show what would change without writing anything
  -h, --help       Show this message

What it does:
  1. Copies every skills/<name>/SKILL.md folder into the target skills directory.
  2. Adds or updates a marked "Superpowers" block in the project's AGENTS.md pointing at
     those skills. That block replaces the SessionStart hook Claude Code's plugin uses;
     Freebuff has no hooks.
  3. Leaves the rest of AGENTS.md untouched.

Windows: run this from Git Bash, or use install.ps1 from PowerShell.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -g|--global) GLOBAL=1 ;;
    --no-bootstrap) DO_BOOTSTRAP=0 ;;
    -f|--force) FORCE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --dir)
      [ $# -ge 2 ] || die "--dir needs a path"
      PROJECT_ROOT="$(cd -- "$2" 2>/dev/null && pwd)" || die "no such directory: $2"
      shift
      ;;
    --dir=*)
      PROJECT_ROOT="$(cd -- "${1#--dir=}" 2>/dev/null && pwd)" || die "no such directory: ${1#--dir=}"
      ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

[ -f "$SOURCE_BOOTSTRAP" ] || die "missing $SOURCE_BOOTSTRAP"
[ -d "$SOURCE_SKILLS" ] || die "missing $SOURCE_SKILLS"

# Build the bootstrap block from bootstrap.md's fenced example, so the documentation and
# the installer can never drift apart.
bootstrap_block() {
  local root="$1"
  sed -n '/^```markdown$/,/^```$/p' "$SOURCE_BOOTSTRAP" |
    sed '1d;$d' |
    sed "s|<SKILLS_ROOT>|$root|g"
}

if [ "$GLOBAL" -eq 1 ]; then
  TARGET_SKILLS="$HOME/.agents/skills"
  # Agents may not expand "~", and a Windows path with backslashes reads badly in
  # Markdown, so use an absolute mixed path where we can.
  if command -v cygpath >/dev/null 2>&1; then
    SKILLS_ROOT="$(cygpath -m "$HOME")/.agents/skills"
  else
    SKILLS_ROOT="$HOME/.agents/skills"
  fi
else
  TARGET_SKILLS="$PROJECT_ROOT/.agents/skills"
  SKILLS_ROOT=".agents/skills"
fi

skills=()
for dir in "$SOURCE_SKILLS"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || die "skills/$name has no SKILL.md"
  skills+=("$name")
done
[ ${#skills[@]} -gt 0 ] || die "no skills found in $SOURCE_SKILLS"

printf 'freebuff-superpowers: %d skills (%s)\n' "${#skills[@]}" "$(printf '%s, ' "${skills[@]}" | sed 's/, $//')"
printf 'target:  %s%s\n' "$TARGET_SKILLS" "$([ "$DRY_RUN" -eq 1 ] && printf '  [dry run]')"

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$TARGET_SKILLS"
fi

for name in "${skills[@]}"; do
  src="$SOURCE_SKILLS/$name"
  dst="$TARGET_SKILLS/$name"

  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
    printf '  = %s (exists, kept -- use --force to replace)\n' "$name"
    continue
  fi

  if [ -e "$dst" ]; then
    printf '  ~ %s (replaced)\n' "$name"
    [ "$DRY_RUN" -eq 1 ] || rm -rf "$dst"
  else
    printf '  + %s\n' "$name"
  fi

  [ "$DRY_RUN" -eq 1 ] || cp -R "$src" "$dst"
done

write_bootstrap() {
  local file="$1"
  local block
  block="$(bootstrap_block "$2")"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      printf 'AGENTS.md: would be created\n'
      return
    fi
    printf '%s\n' "$block" >"$file"
    printf 'AGENTS.md: created\n'
    return
  fi

  local has_start=0 has_end=0
  if grep -qF -- "$START_MARKER" "$file"; then has_start=1; fi
  if grep -qF -- "$END_MARKER" "$file"; then has_end=1; fi

  if [ "$has_start" -ne "$has_end" ]; then
    die "$file has only one freebuff-superpowers marker. Remove the stray marker and run again."
  fi

  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "$block" >"$tmp"

  if [ "$has_start" -eq 1 ]; then
    awk -v s="$START_MARKER" -v e="$END_MARKER" -v bf="$tmp" '
      !skipping && index($0, s) == 1 {
        while ((getline line < bf) > 0) print line
        close(bf)
        skipping = 1
        replaced = 1
        next
      }
      skipping && index($0, e) == 1 { skipping = 0; next }
      skipping { next }
      { print }
    ' "$file" >"$tmp.out"
  else
    awk '{ line[NR] = $0 } END {
      n = NR
      while (n > 0 && line[n] ~ /^[[:space:]]*$/) n--
      for (i = 1; i <= n; i++) print line[i]
    }' "$file" >"$tmp.out"
    if [ -s "$tmp.out" ]; then printf '\n' >>"$tmp.out"; fi
    printf '%s\n' "$block" >>"$tmp.out"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    rm -f "$tmp" "$tmp.out"
    if [ "$has_start" -eq 1 ]; then
      printf 'AGENTS.md: would be updated\n'
    else
      printf 'AGENTS.md: would be appended\n'
    fi
    return
  fi

  local before after
  before="$(cksum <"$file")"
  mv "$tmp.out" "$file"
  rm -f "$tmp"
  after="$(cksum <"$file")"

  if [ "$before" = "$after" ]; then
    printf 'AGENTS.md: unchanged\n'
  elif [ "$has_start" -eq 1 ]; then
    printf 'AGENTS.md: updated\n'
  else
    printf 'AGENTS.md: appended\n'
  fi
}

if [ "$DO_BOOTSTRAP" -eq 1 ]; then
  write_bootstrap "$PROJECT_ROOT/AGENTS.md" "$SKILLS_ROOT"
else
  printf 'AGENTS.md: skipped (--no-bootstrap)\n'
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\nDry run: nothing was written.\n'
  exit 0
fi

cat <<EOF

Next:
  1. Start a new Freebuff session so the skills are discovered.
  2. Confirm they loaded: /skill:brainstorming   (or /skill:using-superpowers)
  3. Then just describe the work. The AGENTS.md block is what makes the agent reach
     for a skill instead of jumping straight to code.
EOF
