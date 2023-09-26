#!/usr/bin/env ruby

class ProjectCompletion
  #Edit file with one line per root directory for auto project completion
  PROJECT_ROOTS_PATH = '~/.terminal/completion_scripts/project_completion_roots'.freeze
  ROOT_PROJECTS_PATH = begin
    path = File.expand_path(PROJECT_ROOTS_PATH)
    path = File.readlink(path) if File.symlink?(path)
    path
  end.freeze
  ROOT_PROJECTS = begin
    if File.exist?(ROOT_PROJECTS_PATH)
      # paths = File.open(ROOT_PROJECTS_PATH, 'r').readlines.collect(&:strip)
      # Dir.glob(paths) # Not switching folder when globs exist in project_completion_roots
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
    `ls #{ROOT_PROJECTS.join(' ')}`.split
  end.freeze

  def initialize(command)
    @command = command
  end

  def matches
    PROJECTS.select do |task|
      task[0, typed.length] == typed
    end
  end

  def typed
    @typed ||= @command && @command[/\s(.+?)$/, 1] || ''
  end
end

puts ProjectCompletion.new(ENV["COMP_LINE"]).matches
exit 0
