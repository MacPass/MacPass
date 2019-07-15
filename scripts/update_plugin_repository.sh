#!/bin/bash
URL="https://macpassapp.org/data/plugins.json"
MY_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOWNLOAD_FOLDER="${MY_FOLDER}/../MacPass/Resources/"
cd "${DOWNLOAD_FOLDER}"
wget "${URL}"
