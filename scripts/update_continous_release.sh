#!/bin/bash
git tag -d continuous
git tag continuous
git push -f origin continuous
