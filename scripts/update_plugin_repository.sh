#!/bin/bash
FILE="plugins.json"
URL="https://macpassapp.org/data/${FILE}"
MY_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOWNLOAD_FOLDER="${MY_FOLDER}/../MacPass/Resources/"
cd "${DOWNLOAD_FOLDER}"
wget -O "${FILE}" "${URL}"
