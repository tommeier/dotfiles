require 'rake'
require 'erb'
require 'fileutils'

desc "install the dot files into user's home directory"
task :install do
  replace_all = ENV['REPLACE_ALL'] == 'true' ? true : false

  preload_private_environment

  Dir['*'].each do |file|
    next if %w[Rakefile README.rdoc LICENSE symlinks].include? file

    if File.exist?(File.join(ENV['HOME'], ".#{file.sub('.erb', '')}"))
      if File.identical? file, File.join(ENV['HOME'], ".#{file.sub('.erb', '')}")
        puts "identical ~/.#{file.sub('.erb', '')}"
      elsif replace_all
        replace_file(file)
      else
        print "overwrite ~/.#{file.sub('.erb', '')}? [ynaq] "
        case $stdin.gets.chomp
        when 'a'
          replace_all = true
          replace_file(file)
        when 'y'
          replace_file(file)
        when 'q'
          exit
        else
          puts "skipping ~/.#{file.sub('.erb', '')}"
        end
      end
    else
      link_file(file)
    end
  end
  setup_symlinks
end

def replace_file(file)
  system %Q{rm -rf "$HOME/.#{file.sub('.erb', '')}"}
  link_file(file)
end

def link_file(file)
  if file =~ /.erb$/
    puts "generating ~/.#{file.sub('.erb', '')}"
    File.open(File.join(ENV['HOME'], ".#{file.sub('.erb', '')}"), 'w') do |new_file|
      new_file.write ERB.new(File.read(file)).result(binding)
    end
  else
    puts "linking ~/.#{file}"
    system %Q{ln -s "$PWD/#{file}" "$HOME/.#{file}"}
  end
end

def setup_symlinks
  puts "Setting up symlinks..."
  #Sublime text 3
  #Package Control.sublime-settings + Preferences.sublime-settings
  symlinks_source_directory = "#{ENV['HOME']}/Library/Application Support/Sublime Text 3/Packages/User/"
  symlinks_dotfiles_directory = File.join('symlinks', 'Sublime Text User Settings')
  symlink_collection(
    symlinks_source_directory,
    symlinks_dotfiles_directory,
    'Sublime Text',
    [
      'Package Control.cache',
      'Package Control.last-run',
      'Package Control.merged-ca-bundle',
      'Package Control.user-ca-bundle',
      'oscrypto-ca-bundle.crt'
    ]
  )
end

#Symlink each directory/file in source directory to a target directory
# Caveat - In root directory, it must be *either* a folder or file wanting to be symlinked
def symlink_collection(source_directory, dotfiles_directory, running_process_to_kill = nil, file_exclusions = [])
  puts " -- Generating symlinks for '#{File.basename(dotfiles_directory)}' -> '#{File.basename(source_directory)}'"
  FileUtils.mkdir_p(dotfiles_directory) unless File.exists?(dotfiles_directory)
  Dir.glob(File.join(source_directory, '*')).each do |file|
    if file_exclusions.include?(File.basename(file))
      puts "Skipping - #{file}"
      next
    else
      puts "Processing - #{file}"
    end
    is_directory = File.directory?(file)

    source_path   = File.expand_path(file)
    dotfiles_path = File.join(File.expand_path(dotfiles_directory), File.basename(file))
    if File.symlink?(source_path) && File.readlink(source_path) == dotfiles_path && File.exists?(dotfiles_path)
      #Symlink already exists and content exists in dotfiles
      puts " --- Symlink exists already '#{dotfiles_path}' --> '#{source_path}'"
    else
      #Generate symlink
      kill_running_process(running_process_to_kill) if running_process_to_kill

      if File.exists?(source_path) && !File.symlink?(source_path)
        # First run
        puts "     - Removing existing source for '#{File.basename(file)}' and moving to dotfiles location."
        if File.exists?(dotfiles_path)
          is_directory ? FileUtils.rm_rf(dotfiles_path) : FileUtils.rm(dotfiles_path)
        end

        FileUtils.mv(source_path, dotfiles_path)
      elsif File.exists?(source_path)
        puts "     - Removing existing target for '#{File.basename(file)}'."
        is_directory ? FileUtils.rm_rf(source_path) : FileUtils.rm(source_path)
      end

      puts " --+ Linking '#{dotfiles_path}' --> '#{source_path}'"

      system %Q{ln -s "#{dotfiles_path}" "#{source_path}"}
    end
  end
  puts " -- Done."
end

def kill_running_process(process_name)
  pid = `pgrep '#{process_name}'`
  unless pid.to_s == ''
    puts " ** Killing running process : '#{process_name}' - #{pid}"
    Process.kill "USR2", pid.to_i
  end
end

#Babushka loads in one ruby process, this will load any env file previously generated (like in private-dot-files)
# Search and match on any variable assignment and ensure current ruby process has it loaded
def preload_private_environment(private_file_location = File.join(ENV['HOME'], '.localrc'))
  if File.exists?(private_file_location)
    File.open(private_file_location).read.scan(/^([\w_]+)\=["']?([^"']+)["']?$/) do |key, value|
      ENV[key] = value
    end
  end
end
