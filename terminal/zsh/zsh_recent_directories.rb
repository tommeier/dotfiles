#!/usr/bin/env ruby

class ZshRecentDirectories
  #Edit file with one line per root directory for auto project completion
  PROJECT_ROOTS_PATH = '~/.terminal/completion_scripts/project_completion_roots'.freeze
  ROOT_PROJECTS_PATH = begin
    path = File.expand_path(PROJECT_ROOTS_PATH)
    path = File.readlink(path) if File.symlink?(path)
    path
  end.freeze
  ROOT_PROJECTS = begin
    if File.exist?(ROOT_PROJECTS_PATH)
      File.open(ROOT_PROJECTS_PATH, 'r').readlines.inject([]) do |result, root_path|
        cleaned_path = root_path.strip
        result << cleaned_path if Dir.exist?(cleaned_path)
        result
      end
    else
      []
    end
  end.freeze
  PROJECTS = begin
    `ls -d #{ROOT_PROJECTS.map {|path| path << '*' }.join(' ') } 2> /dev/null`.split
  end.freeze

  def initialize(command)
    @command = command
  end

  def projects
    PROJECTS.each { |path| path.chop! if path[-1,1] == '/' }.compact.uniq
  end
end

puts ZshRecentDirectories.new(ENV["COMP_LINE"]).projects
exit 0
