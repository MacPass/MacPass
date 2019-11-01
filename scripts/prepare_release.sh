#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--sign)
    IDENTITY="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--username)
    USERNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--entitlements)
    ENTITLEMENTS="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -z "${IDENTITY}" ]]; then
    echo "Missing identity"
    exit -1
fi
if [[ -z "${ENTITLEMENTS}" ]]; then
    echo "Missing entitlements"
    exit -1
fi
if [[ -z "${USERNAME}" ]]; then
    echo "Missing username"
    exit -1
fi
if [[ -z "${PASSWORD}" ]]; then
    echo "Missing password"
    exit -1
fi

BUILD_FOLDER="${TMPDIR}"
APP_BUNDLE=MacPass.app
APP_BUNDLE_ZIP="${APP_BUNDLE}".zip
cd ..
xcodebuild build -configuration Release -project MacPass.xcodeproj -scheme MacPass CODE_SIGNING_REQUIRED=NO -derivedDataPath "${BUILD_FOLDER}"
cd "${BUILD_FOLDER}"
echo codesign --sign "${IDENTITY}" --options runtime --deep --force --entitlements "${ENTITLEMENTS}" "${APP_BUNDLE}"
echo ditto -c -k --keepParent "${APP_BUNDLE}" "${APP_BUNDLE_ZIP}"
xcrun altool --notarize-app --primary-bundle-id "com.hicknhacksoftware.MacPass.zip" --username "${USERNAME}" --password "${PASSWORD}" --file "${APP_BUNDLE_ZIP}"
#xcrun stapler staple "${APP_BUNDLE}"
