#!/bin/bash -e

export PS1="\w$ "

# Generic bash commands

function check_gems_outdated {
  if [ -f ./Gemfile ]; then
    bundle outdated
  fi
}

function check_yarn_outdated {
  if [ -f ./yarn.lock ]; then
    yarn outdated
  fi
}

function check_pods_outdated {
  if [ -f ./Gemfile ]; then
    if [ -f ./Podfile ]; then
      bundle exec pod outdated
    fi
  else
    if [ -f ./Podfile ]; then
      pod outdated
    fi
  fi
}

function outdated {
  check_gems_outdated
  check_pods_outdated
  check_yarn_outdated
}
