#!/usr/bin/env bash

set -euo pipefail

if jq -e 'index("no-user-facing-impact") != null' <<< "$PR_LABELS" > /dev/null; then
  echo "The no-user-facing-impact label is present."
  exit 0
fi

merge_base=$(git merge-base "$BASE_SHA" "$HEAD_SHA")
git show "$merge_base:CHANGELOG.md" > "$RUNNER_TEMP/changelog-base.md"
git show "$HEAD_SHA:CHANGELOG.md" > "$RUNNER_TEMP/changelog-head.md"

extract_entries() {
  awk -v target="$2" '
    function emit() {
      if (entry != "") print category "\t" entry
      entry = ""
    }
    /^[[:space:]]*<!--/ { comment = 1 }
    comment {
      if ($0 ~ /-->/) comment = 0
      next
    }
    /^[[:space:]]*(```|~~~)/ { fenced = !fenced; next }
    fenced { next }
    /^## / {
      if (section) { emit(); exit }
      if ((target == "Unreleased" && $0 ~ /^## Unreleased[[:space:]]*$/) ||
          (target != "Unreleased" && index($0, "## [" target "](") == 1)) {
        section = 1
      }
      next
    }
    section && /^### / {
      emit()
      category = substr($0, 5)
      valid = category ~ /^(Added|Changed|Deprecated|Removed|Fixed|Security)$/
      next
    }
    section && valid && /^- [^[:space:]]/ {
      emit()
      entry = substr($0, 3)
      next
    }
    section && entry != "" && /^[[:space:]][[:space:]]+[^[:space:]]/ {
      continuation = $0
      sub(/^[[:space:]]+/, "", continuation)
      entry = entry " " continuation
      next
    }
    END { emit() }
  ' "$1" | sort -u
}

extract_entries "$RUNNER_TEMP/changelog-base.md" Unreleased > "$RUNNER_TEMP/changelog-base-entries.txt"
extract_entries "$RUNNER_TEMP/changelog-head.md" Unreleased > "$RUNNER_TEMP/changelog-head-entries.txt"

if [[ -n "$(comm -13 "$RUNNER_TEMP/changelog-base-entries.txt" "$RUNNER_TEMP/changelog-head-entries.txt")" ]]; then
  echo "CHANGELOG.md contains a new or updated Unreleased entry."
  exit 0
fi

base_version=$(git show "$merge_base:Chart.yaml" | awk '$1 == "version:" { print $2; exit }' | tr -d "\"'")
head_version=$(git show "$HEAD_SHA:Chart.yaml" | awk '$1 == "version:" { print $2; exit }' | tr -d "\"'")

if [[ -n "$head_version" && "$base_version" != "$head_version" ]]; then
  extract_entries "$RUNNER_TEMP/changelog-base.md" "$head_version" > "$RUNNER_TEMP/changelog-base-release.txt"
  extract_entries "$RUNNER_TEMP/changelog-head.md" "$head_version" > "$RUNNER_TEMP/changelog-head-release.txt"

  if [[ -s "$RUNNER_TEMP/changelog-base-entries.txt" ]] \
    && [[ ! -s "$RUNNER_TEMP/changelog-head-entries.txt" ]] \
    && [[ ! -s "$RUNNER_TEMP/changelog-base-release.txt" ]] \
    && [[ -z "$(comm -23 "$RUNNER_TEMP/changelog-base-entries.txt" "$RUNNER_TEMP/changelog-head-release.txt")" ]]; then
    echo "CHANGELOG.md moves all Unreleased entries into the new $head_version release section."
    exit 0
  fi
fi

echo "Add an entry under an allowed category in CHANGELOG.md's Unreleased section or apply the no-user-facing-impact label." >&2
exit 1
