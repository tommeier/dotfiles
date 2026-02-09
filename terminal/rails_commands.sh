# =============================================================================
# Rails Commands
# =============================================================================

# Bundler
alias be="bundle exec"
alias bec='bundle exec c'
alias bes='bundle exec s'
alias bi='bundle install'
alias bu='bundle update'
alias bo='bundle outdated'

# Rails console/server
alias brc='bundle exec rails console'
alias brs='bundle exec rails server'
alias brdb='bundle exec rails db:migrate'
alias brdbs='bundle exec rails db:migrate:status'
alias brdbr='bundle exec rails db:rollback'
alias brdbc='bundle exec rails db:create'
alias brdbd='bundle exec rails db:drop'
alias brdbrs='bundle exec rails db:reset'
alias brr='bundle exec rails routes'

# RSpec
alias ber='bundle exec rspec'
alias berf='bundle exec rspec --fail-fast'
alias berff='bundle exec rspec --fail-fast --only-failures'

# Foreman
# =============================================================================
alias fs="bundle exec foreman start"
function fr {
  bundle exec foreman run "$@"
}

#Kill any processes related to a specific port
# USAGE : kill_port 3000
function kill_port {
  lsof -Fp -i :$1 | cut -c 2- | xargs kill
}

function delete_gem_list {
  echo "Uninstalling all system gems... This could take a while..."
  for x in $(gem list --no-versions); do gem uninstall "$x" --all --quiet --ignore-dependencies --user-install --executables; done
}


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

function assets_nuke {
  rm -rf tmp/cache
  rm -rf public/assets
}
