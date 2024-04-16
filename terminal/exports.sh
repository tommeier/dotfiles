#!/bin/bash -e

export EDITOR='subl --wait'
# export ARCHFLAGS="-arch x86_64";

# Prefer AU English and use UTF-8
export LANG="en_AU"
export LC_ALL="en_AU.UTF-8"

# Disable docker for local dev and use asdf
export DEV_DOCKER="false"
