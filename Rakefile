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
  ensure_gpg_signing_key

  DOTFILES.each do |file|
    next unless File.exist?(file)

    install_dotfile(file, replace_all: replace_all)
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

  File.read(file_path).scan(/^export\s+([\w_]+)=["']?([^"'\n]+)["']?$/) do |key, value|
    ENV[key] = value
  end
end

# Ensure GPG_SIGNING_KEY is set, auto-detecting or prompting if needed
def ensure_gpg_signing_key
  return if ENV['GPG_SIGNING_KEY'] && !ENV['GPG_SIGNING_KEY'].empty?

  puts "\n⚠️  GPG_SIGNING_KEY not set. Detecting available keys..."

  keys = detect_gpg_keys
  if keys.empty?
    puts "  No GPG keys found. Skipping (run 'gpg --gen-key' to create one)."
    return
  end

  selected_key = if keys.length == 1
                   puts "  Found: #{keys.first[:id]} (#{keys.first[:uid]})"
                   keys.first[:id]
                 else
                   prompt_for_gpg_key(keys)
                 end

  return unless selected_key

  ENV['GPG_SIGNING_KEY'] = selected_key
  save_gpg_key_to_localrc(selected_key)
end

def detect_gpg_keys
  output = `gpg --list-secret-keys --keyid-format LONG 2>/dev/null`
  keys = []

  output.scan(/^sec\s+\w+\/(\w+).*?\nuid\s+\[.*?\]\s+(.+)$/m) do |id, uid|
    keys << { id: id, uid: uid.strip }
  end

  keys
end

def prompt_for_gpg_key(keys)
  puts "  Multiple GPG keys found:"
  keys.each_with_index do |key, i|
    puts "    #{i + 1}) #{key[:id]} - #{key[:uid]}"
  end

  print "  Select key [1]: "
  choice = $stdin.gets.chomp
  choice = '1' if choice.empty?

  index = choice.to_i - 1
  if index >= 0 && index < keys.length
    keys[index][:id]
  else
    puts "  Invalid choice, skipping."
    nil
  end
end

def save_gpg_key_to_localrc(key)
  localrc_path = File.join(HOME, '.localrc')
  content = File.exist?(localrc_path) ? File.read(localrc_path) : ''

  if content.match?(/^export GPG_SIGNING_KEY=/)
    content.gsub!(/^export GPG_SIGNING_KEY=.*$/, "export GPG_SIGNING_KEY=\"#{key}\"")
  else
    content += "\nexport GPG_SIGNING_KEY=\"#{key}\"\n"
  end

  File.write(localrc_path, content)
  File.chmod(0o600, localrc_path)
  puts "  ✅ Saved GPG_SIGNING_KEY=#{key} to ~/.localrc"
  puts "  ℹ️  Run 'REPLACE_ALL=true rake install' to regenerate ~/.gitconfig with the new key."
end
