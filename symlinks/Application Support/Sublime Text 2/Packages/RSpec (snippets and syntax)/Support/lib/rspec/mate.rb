# This is based on Florian Weber's TDDMate

ENV['TM_PROJECT_DIRECTORY'] ||= File.dirname(ENV['TM_FILEPATH'])

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/..')

require 'rspec/mate/runner'
require 'rspec/mate/options'
require 'rspec/mate/switch_command'

rspec_lib = nil

# TODO: move to Options
def bundler_option?
  RSpec::Mate::Options['--bundler']
end

# TODO: move to Options
def skip_bundler_option?
  RSpec::Mate::Options['--skip-bundler']
end

def find_rspec_lib
  candidate_rspec_lib_paths = Dir.glob(
    File.join(
      ENV['TM_PROJECT_DIRECTORY'],
      'vendor',
      '{plugins,gems}',
      '{rspec,rspec-core}{,-[0-9]*}',
      'lib'
    )
  )

  if ENV['TM_RSPEC_HOME']
    candidate_rspec_lib_paths << File.join(
      ENV['TM_RSPEC_HOME'],
      'lib'
    )
  end

  rspec_lib = candidate_rspec_lib_paths.detect do |dir|
    File.exist?(dir)
  end
end

def gemfile?
  File.exist?(File.join(ENV['TM_PROJECT_DIRECTORY'], 'Gemfile'))
end

def use_bundler?
  bundler_option? || (gemfile? && skip_bundler_option?)
end


if use_bundler?
  require "rubygems"
  require "bundler"

  Bundler.setup
else
  rspec_lib = find_rspec_lib

  if rspec_lib
    $LOAD_PATH.unshift(rspec_lib)
  end
end

if RSpec::Mate::Options['--rspec-version']
  if RSpec::Mate::Options['--rspec-version'] =~ /^2/
    require 'rspec/core'
  else
    require 'spec/autorun'
  end
elsif rspec_lib
  if File.exist?(File.join(rspec_lib, 'rspec', 'core.rb'))
    require 'rspec/core'
  else
    require 'spec/autorun'
  end
else
  begin
    require 'rspec/core'
  rescue LoadError
    require 'spec/autorun'
  end
end

def rspec2?
  defined?(RSpec::Core)
end
