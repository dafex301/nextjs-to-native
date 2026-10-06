#!/usr/bin/env bash
# PreToolUse guard for native migration repos.
# Blocks agent edits to files that must change through a generator, the IDE, or a human.
# Install: copy to .claude/hooks/guard-paths.sh, chmod +x, and register it via templates/hooks.json.
# Edit PROTECTED below to fit the project (e.g. add the generated API client directory).
set -euo pipefail

PROTECTED=(
  '*.pbxproj'                 # regenerate with XcodeGen/Tuist instead
  '*.xcodeproj/*'
  '*.xcworkspace/*'
  '*.entitlements'            # capabilities change via project.yml + human review
  '*/migration/baselines/*'   # web baselines are the spec; re-capture deliberately
  '*/build/generated/*'       # generated OpenAPI client (Android)
  '*/GeneratedSources/*'      # generated OpenAPI client (iOS)
  '*.jks'                     # signing keys
  '*.keystore'
  '*.p12'
  '*.mobileprovision'
  '*/google-services.json'
  '*/GoogleService-Info.plist'
)

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')"
[ -z "$file" ] && exit 0

for pattern in "${PROTECTED[@]}"; do
  # shellcheck disable=SC2053
  if [[ "$file" == $pattern ]]; then
    echo "Blocked: $file is protected ($pattern). Change it through its generator/IDE, or ask the user to edit it." >&2
    exit 2
  fi
done
exit 0
