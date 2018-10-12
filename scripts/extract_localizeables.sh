#!/bin/bash
find ../MacPass/. -name \*.m | xargs genstrings -o .
mv Localizable.strings ../MacPass/en.lproj/Localizable.strings.updated
