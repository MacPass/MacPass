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

DERIVED_DATA_FOLDER="${TMPDIR}"
BUILD_FOLDER="${DERIVED_DATA_FOLDER}"/Build/Products/Release
APP_BUNDLE=MacPass.app
APP_BUNDLE_ZIP="${APP_BUNDLE}".zip
APP_FRAMEWORK_PATH="${APP_BUNDLE}"/Contents/Frameworks
SPARKLE_FRAMEWORK="${APP_FRAMEWORK_PATH}"/Sparkle.framework
SPARKLE_AUTOUPDATE_BUNDLE="${SPARKLE_FRAMEWORK}"/Resources/Autoupdate.app
SPARKLE_FILEOP="${SPARKLE_AUTOUPDATE_BUNDLE}"/Contents/MacOS/fileop
TRANSFORMERKIT_FRAMEWORK="${APP_FRAMEWORK_PATH}"/TransformerKit.framework
KEEPASSKIT_FRAMEWORK="${APP_FRAMEWORK_PATH}"/KeePassKit.framework
KISSXML_FRAMEWORK="${KEEPASSKIT_FRAMEWORK}"/Versions/Current/Frameworks/KissXML.framework
HNHUI_FRAMEWORK="${APP_FRAMEWORK_PATH}"/HNHUi.framework
cd ..
echo "Building..."
xcodebuild build -configuration Release -project MacPass.xcodeproj -scheme MacPass CODE_SIGNING_REQUIRED=NO -derivedDataPath "${DERIVED_DATA_FOLDER}"
cd "${BUILD_FOLDER}"
echo ""
echo "Signing Sparkle - fileop..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${SPARKLE_FILEOP}"
echo "Signing Sparkle - Autoupdate..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${SPARKLE_AUTOUPDATE_BUNDLE}"
echo "Signing Sparkle..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${SPARKLE_FRAMEWORK}"
echo "Signing TransformerKit..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${TRANSFORMERKIT_FRAMEWORK}"
echo "Signing HNHUi..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${HNHUI_FRAMEWORK}"
echo "Signing KeePassKit - KissXML..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${KISSXML_FRAMEWORK}"
echo "Signing KeePassKit..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${KEEPASSKIT_FRAMEWORK}"
echo "Signing MacPass..."
codesign --sign "${IDENTITY}" --options runtime --force --entitlements "${ENTITLEMENTS}" "${APP_BUNDLE}"
echo ""
echo "Archiving..."
ditto -c -k --keepParent "${APP_BUNDLE}" "${APP_BUNDLE_ZIP}"
echo "Requesting Notarization..."
xcrun altool --notarize-app --primary-bundle-id "com.hicknhacksoftware.MacPass.zip" --username "${USERNAME}" --password "${PASSWORD}" --file "${APP_BUNDLE_ZIP}"
#xcrun stapler staple "${APP_BUNDLE}"
#xmllint --xpath "/plist/dict/key[contains(text(),'success-message')]::following-sibling" status.xml