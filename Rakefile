# frozen_string_literal: true

require 'rake'
require 'erb'
require 'fileutils'

# Explicit list of dotfiles to install (symlinked to ~/.filename)
DOTFILES = %w[
  zshrc
  zprofile
  bashrc
  bash_profile
  gitconfig.erb
  gitignore
  gitk
  irbrc
  pryrc
  psqlrc
  gemrc
  railsrc
  ackrc
  terminal
  bin
  .tool-versions
  .ruby-version
  git-prompt-colors.sh
].freeze

HOME = ENV.fetch('HOME')

# Install dotfiles to home directory
# Set REPLACE_ALL=true to skip prompts
desc 'Install dotfiles into home directory'
task :install do
  replace_all = ENV['REPLACE_ALL'] == 'true'

  preload_private_environment

  DOTFILES.each do |file|
    next unless File.exist?(file)

    install_dotfile(file, replace_all:)
  end

  puts "\nDotfiles installed successfully."
end

task default: :install

private

def install_dotfile(file, replace_all: false)
  target_name = file.delete_prefix('.').sub(/\.erb$/, '')
  target_path = File.join(HOME, ".#{target_name}")

  puts "Processing: #{file}"

  if File.exist?(target_path)
    if File.identical?(file, target_path)
      puts "  identical ~/.#{target_name}"
    elsif replace_all
      replace_file(file)
    else
      handle_existing_file(file, target_name)
    end
  else
    link_file(file)
  end
end

def handle_existing_file(file, target_name)
  print "  overwrite ~/.#{target_name}? [ynaq] "
  case $stdin.gets.chomp
  when 'a'
    replace_file(file)
    true
  when 'y'
    replace_file(file)
    false
  when 'q'
    exit
  else
    puts "  skipping ~/.#{target_name}"
    false
  end
end

def replace_file(file)
  target_name = file.delete_prefix('.').sub(/\.erb$/, '')
  FileUtils.rm_rf(File.join(HOME, ".#{target_name}"))
  link_file(file)
end

def link_file(file)
  target_name = file.delete_prefix('.').sub(/\.erb$/, '')

  if file.end_with?('.erb')
    puts "  generating ~/.#{target_name}"
    File.write(
      File.join(HOME, ".#{target_name}"),
      ERB.new(File.read(file)).result(binding)
    )
  else
    puts "  linking ~/.#{target_name}"
    FileUtils.ln_sf(File.expand_path(file), File.join(HOME, ".#{target_name}"))
  end
end

# Load environment variables from private file (e.g., ~/.localrc)
# Used to populate ERB templates with private values
def preload_private_environment(file_path = File.join(HOME, '.localrc'))
  return unless File.exist?(file_path)

  File.read(file_path).scan(/^([\w_]+)=["']?([^"']+)["']?$/) do |key, value|
    ENV[key] = value
  end
end
