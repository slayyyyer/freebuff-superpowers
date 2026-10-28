#!/usr/bin/env bash
# Validates every skill against Freebuff's skill rules and checks that the bootstrap
# routes to all of them.
#
# Freebuff rejects invalid skills silently, so a broken name shows up as a skill that
# simply never loads. Run this before shipping any change.
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
BOOTSTRAP="$ROOT/bootstrap.md"

START_MARKER='<!-- freebuff-superpowers:start -->'
END_MARKER='<!-- freebuff-superpowers:end -->'

failures=0
warnings=0

err() {
  printf 'fail  %s\n' "$*" >&2
  failures=$((failures + 1))
}

warn() {
  printf 'warn  %s\n' "$*"
  warnings=$((warnings + 1))
}

[ -d "$SKILLS_DIR" ] || { echo "no skills directory at $SKILLS_DIR" >&2; exit 1; }
[ -f "$BOOTSTRAP" ] || { echo "no $BOOTSTRAP" >&2; exit 1; }

skills=()
for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  skills+=("$(basename "$dir")")
done

if [ ${#skills[@]} -eq 0 ]; then
  err "no skills found"
fi

for name in "${skills[@]}"; do
  file="$SKILLS_DIR/$name/SKILL.md"
  label="skills/$name/SKILL.md"

  if [ ! -f "$file" ]; then
    err "skills/$name: directory has no SKILL.md"
    continue
  fi

  content="$(tr -d '\r' <"$file")"

  if [ "$(printf '%s\n' "$content" | head -n 1)" != "---" ]; then
    err "$label: does not start with YAML frontmatter (---)"
    continue
  fi

  close_line="$(printf '%s\n' "$content" | awk 'NR > 1 && $0 == "---" { print NR; exit }')"
  if [ -z "$close_line" ]; then
    err "$label: frontmatter is never closed with ---"
    continue
  fi

  frontmatter="$(printf '%s\n' "$content" | awk -v c="$close_line" 'NR > 1 && NR < c')"
  body="$(printf '%s\n' "$content" | awk -v c="$close_line" 'NR > c')"

  fm_name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
  fm_desc="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -n 1)"

  if [ -z "$fm_name" ]; then
    err "$label: missing required field \"name\""
  else
    if [ "${#fm_name}" -gt 64 ]; then
      err "$label: name is longer than 64 characters"
    fi
    if ! printf '%s' "$fm_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      err "$label: name \"$fm_name\" must be lowercase letters, digits and single hyphens, with no leading or trailing hyphen"
    fi
    if [ "$fm_name" != "$name" ]; then
      err "$label: name \"$fm_name\" does not match directory \"$name\""
    fi
  fi

  if [ -z "$fm_desc" ]; then
    err "$label: missing required field \"description\""
  else
    desc_length=${#fm_desc}
    if [ "$desc_length" -lt 20 ]; then
      warn "$label: description is only $desc_length characters; it will under-trigger"
    fi
    if [ "$desc_length" -gt 1024 ]; then
      err "$label: description is $desc_length characters (max 1024)"
    fi
    if ! printf '%s' "$fm_desc" | grep -Eqi '^use '; then
      warn "$label: description should start with \"Use when ...\" so the trigger is explicit"
    fi
  fi

  if [ -z "$(printf '%s\n' "$body" | tr -d '[:space:]')" ]; then
    err "$label: body is empty"
  else
    body_lines="$(printf '%s\n' "$body" | wc -l | tr -d ' ')"
    if [ "$body_lines" -gt 200 ]; then
      warn "$label: body is $body_lines lines; consider splitting it"
    fi
    if ! printf '%s\n' "$body" | grep -q '^## '; then
      warn "$label: body has no \"## \" sections"
    fi
  fi

  if ! grep -qF -- "/$name/SKILL.md" "$BOOTSTRAP"; then
    err "bootstrap.md: never routes to \"$name\""
  fi
done

if ! grep -qF -- "$START_MARKER" "$BOOTSTRAP"; then
  err "bootstrap.md: missing the start marker used by the installers"
fi
if ! grep -qF -- "$END_MARKER" "$BOOTSTRAP"; then
  err "bootstrap.md: missing the end marker used by the installers"
fi

if [ "$failures" -gt 0 ]; then
  printf '\n%d problem(s) across %d skills.\n' "$failures" "${#skills[@]}" >&2
  exit 1
fi

printf 'ok: %d skills, %d warning(s) -- %s\n' \
  "${#skills[@]}" "$warnings" "$(printf '%s, ' "${skills[@]}" | sed 's/, $//')"
