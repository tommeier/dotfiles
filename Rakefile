require 'rake'
require 'erb'
require 'fileutils'

desc "install the dot files into user's home directory"
task :install do
  replace_all = false

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

#Symlink each directory in source directory to a target directory
def symlink_folders(source_directory, target_directory)

  puts " -- Generating symlinks for '#{File.basename(source_directory)}'"
  Dir.glob(File.join(source_directory, '*')).each do |file|

    if File.directory?(file)
      symlink_source = File.expand_path(file)
      symlink_target = File.join(target_directory, File.basename(file))

      if File.exists?(symlink_target)
        puts "     - Removing existing target for '#{File.basename(file)}'."
        FileUtils.rm_rf(symlink_target)
      end

      puts " --+ Linking '#{symlink_source}' --> '#{symlink_target}'"
      system %Q{ln -s "#{symlink_source}" "#{symlink_target}"}
    end
  end
  puts " -- Done."

end

desc "Setup symlinks"
task :setup_symlinks do
  #TODO : Automate this for all files/folders present in the app_support directory
  #Sublime text 2
  puts "Setting up symlinks..."

  symlink_folders(File.join('symlinks', 'Application Support', 'Sublime Text 2'), '/users/tom/Library/Application Support/Sublime Text 2/')

end
