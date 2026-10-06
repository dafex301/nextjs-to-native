#!/usr/bin/env bash
# PostToolUse formatter: formats the Kotlin or Swift file the agent just wrote.
# Install: copy to .claude/hooks/format-file.sh, chmod +x, and register it via templates/hooks.json.
# Never fails the tool call: formatting problems are reported, not blocking.
set -uo pipefail

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

case "$file" in
  *.kt|*.kts)
    command -v ktlint >/dev/null && ktlint --format --relative "$file" >/dev/null 2>&1 || true ;;
  *.swift)
    command -v swiftformat >/dev/null && swiftformat --quiet "$file" >/dev/null 2>&1 || true ;;
esac
exit 0
