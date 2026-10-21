#!/bin/bash
# Build with a persistent signing identity so macOS privacy grants survive edits.
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
signing_config="$repo_dir/.local-build.xcconfig"
if [[ ! -f "$signing_config" ]]; then
  echo "Create .local-build.xcconfig as described in README.md before building." >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  set -- build
fi

cd "$repo_dir"
export XCODE_XCCONFIG_FILE="$signing_config"
exec xcodebuild -project MacPass.xcodeproj -scheme MacPass \
  -configuration Debug -derivedDataPath "$repo_dir/build" \
  -destination 'platform=macOS' "$@"
