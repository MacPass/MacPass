#!/bin/bash
# Builds MacPass with its dependencies and starts it, without opening Xcode:
#
#   scripts/run.sh
#
# The first run fetches the DDHotKey submodule, installs Carthage through Homebrew if it is
# missing and builds the frameworks; later runs only rebuild MacPass. The result is a Debug
# build in build/Build/Products/Debug/MacPass.app, signed ad hoc.
set -euo pipefail

MY_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${MY_FOLDER}/.."

DERIVED_DATA="${PWD}/build"
APP="${DERIVED_DATA}/Build/Products/Debug/MacPass.app"
BUILD_LOG="${DERIVED_DATA}/xcodebuild.log"
mkdir -p "${DERIVED_DATA}"

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "Xcode is missing: install it from the App Store and open it once." >&2
  exit 1
fi

if [[ -z "$(ls -A DDHotKey 2>/dev/null)" ]]; then
  git submodule update --init --recursive
fi

# Every Xcode release drops the oldest systems (Xcode 27 builds for macOS 12 and later), while
# MacPass and its frameworks declare 10.13. If the installed SDK refuses that, raise the target
# to the oldest one it accepts, for the frameworks and for MacPass alike.
PROJECT_TARGET="$(sed -n 's/.*MACOSX_DEPLOYMENT_TARGET = \(.*\);/\1/p' MacPass.xcodeproj/project.pbxproj | sort -V | head -1)"
SDK_TARGET="$(plutil -extract SupportedTargets.macosx.MinimumDeploymentTarget raw "$(xcrun --sdk macosx --show-sdk-path)/SDKSettings.json" 2>/dev/null || true)"
if [[ -n "${SDK_TARGET}" && "$(printf '%s\n' "${PROJECT_TARGET}" "${SDK_TARGET}" | sort -V | head -1)" != "${SDK_TARGET}" ]]; then
  echo "This Xcode builds for macOS ${SDK_TARGET} and later, raising the deployment target from ${PROJECT_TARGET}."
  echo "MACOSX_DEPLOYMENT_TARGET = ${SDK_TARGET}" > "${DERIVED_DATA}/deployment-target.xcconfig"
  export XCODE_XCCONFIG_FILE="${DERIVED_DATA}/deployment-target.xcconfig"
fi

# The frameworks are rebuilt only when Cartfile.resolved differs from the one they were built from.
BUILT_FROM="Carthage/Build/Cartfile.resolved"
if ! cmp -s Cartfile.resolved "${BUILT_FROM}"; then
  if ! command -v carthage >/dev/null; then
    if ! command -v brew >/dev/null; then
      echo "Carthage is missing: https://github.com/Carthage/Carthage#installing-carthage" >&2
      exit 1
    fi
    brew install carthage
  fi
  carthage checkout

  # Carthage builds every shared scheme that lists macosx among its platforms, and recent Xcode
  # lists it for iOS targets too, because they can run on a Mac. The iOS schemes of KissXML,
  # KeePassKit and TransformerKit then get built for the Mac and fail. Keep the macOS schemes only.
  for SCHEME_FILE in Carthage/Checkouts/*/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme; do
    SDK_NAME="$(xcodebuild -project "${SCHEME_FILE%/xcshareddata/*}" -scheme "$(basename "${SCHEME_FILE}" .xcscheme)" \
      -showBuildSettings -skipUnavailableActions SUPPORTS_MACCATALYST=NO 2>/dev/null | awk '$1 == "SDK_NAME" { print $3; exit }')"
    if [[ "${SDK_NAME}" != macosx* ]]; then
      rm "${SCHEME_FILE}"
    fi
  done

  # The macOS 27 SDK has no Darwin.Availability and Darwin.C.xlocale modules any more, which
  # TransformerKit imports. Fixed in https://github.com/MacPass/TransformerKit/pull/2; this goes
  # away when the Cartfile points to a commit that has it.
  sed -i '' -e 's|^@import Darwin\.Availability;|#import <Availability.h>|' -e 's|^@import Darwin\.C\.xlocale;|#import <xlocale.h>|' \
    Carthage/Checkouts/TransformerKit/Sources/*.[hm]

  carthage build --platform macOS --cache-builds
  cp Cartfile.resolved "${BUILT_FROM}"
fi

# The project signs with the maintainer's team and an entitlements file that needs a provisioning
# profile. Sign ad hoc and without entitlements instead. The hardened runtime has to be off then:
# without the disable-library-validation entitlement it refuses to load the embedded frameworks.
echo "Building MacPass, log in ${BUILD_LOG}"
if ! xcodebuild build -project MacPass.xcodeproj -scheme MacPass -configuration Debug -derivedDataPath "${DERIVED_DATA}" \
    CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= CODE_SIGN_ENTITLEMENTS= ENABLE_HARDENED_RUNTIME=NO \
    > "${BUILD_LOG}" 2>&1; then
  grep -E "error:|BUILD FAILED" "${BUILD_LOG}" | sort -u >&2
  exit 1
fi

# A running copy of this build is asked to quit, so that it can still offer to save changes.
BINARY="${APP}/Contents/MacOS/MacPass"
if pgrep -f "${BINARY}" >/dev/null; then
  osascript -e "tell application \"${APP}\" to quit" >/dev/null 2>&1 || true
  for _ in $(seq 1 50); do
    pgrep -f "${BINARY}" >/dev/null || break
    sleep 0.2
  done
  if pgrep -f "${BINARY}" >/dev/null; then
    echo "MacPass is still running, maybe with unsaved changes. Quit it and start this script again." >&2
    exit 1
  fi
fi

open -n "${APP}"
