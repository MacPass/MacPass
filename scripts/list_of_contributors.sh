#!/bin/bash
# prints the list of contributors in markdown format
git log --pretty="[%an](%ae)" | sort | uniq
