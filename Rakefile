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

  symlinks_target_file = "#{ENV['HOME']}/Library/Application Support/Sublime Text 3/Packages/User/Package Control.sublime-settings"
  symlinks_source_file = File.join('symlinks', 'Application Support', 'Sublime Text 3', 'Packages', 'User', 'Package Control.sublime-settings')
  symlink_collection(symlinks_source_file, symlinks_target_file, 'Sublime Text 3')

  symlinks_target_file = "#{ENV['HOME']}/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"
  symlinks_source_file = File.join('symlinks', 'Application Support', 'Sublime Text 3', 'Packages', 'User', 'Preferences.sublime-settings')
  symlink_collection(symlinks_source_file, symlinks_target_file, 'Sublime Text 3')
end

#Symlink each directory/file in source directory to a target directory
# Caveat - In root directory, it must be *either* a folder or file wanting to be symlinked
def symlink_collection(source_directory, target_directory, running_process_to_kill = nil)
  puts " -- Generating symlinks for '#{File.basename(source_directory)}'"
  Dir.glob(File.join(source_directory, '*')).each do |file|
    is_directory = File.directory?(file)

    symlink_source = File.expand_path(file)
    symlink_target = File.join(target_directory, File.basename(file))
    if File.symlink?(symlink_target) && File.readlink(symlink_target) == symlink_source
      #Symlink already exists
      puts " --- Symlink exists already '#{symlink_source}' --> '#{symlink_target}'"
    else
      #Generate symlink
      kill_running_process(running_process_to_kill) if running_process_to_kill

      if File.exists?(symlink_target)
        puts "     - Removing existing target for '#{File.basename(file)}'."
        is_directory ? FileUtils.rm_rf(symlink_target) : FileUtils.rm(symlink_target)
      end

      puts " --+ Linking '#{symlink_source}' --> '#{symlink_target}'"
      system %Q{ln -s "#{symlink_source}" "#{symlink_target}"}
    end
  end
  puts " -- Done."
end

def kill_running_process(process_name)
  pid = `pgrep 'Sublime Text 2'`
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
