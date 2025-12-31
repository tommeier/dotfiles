#!/usr/bin/env ruby
# frozen_string_literal: true

class ZshRecentDirectories
  PROJECT_ROOTS_PATH = '~/.terminal/completion_scripts/project_completion_roots'

  ROOT_PROJECTS_PATH = begin
    path = File.expand_path(PROJECT_ROOTS_PATH)
    File.symlink?(path) ? File.readlink(path) : path
  end.freeze

  ROOT_PROJECTS = begin
    if File.exist?(ROOT_PROJECTS_PATH)
      File.readlines(ROOT_PROJECTS_PATH).map do |line|
        expanded = File.expand_path(line.strip)
        expanded if Dir.exist?(expanded)
      end.compact
    else
      []
    end
  end.freeze

  PROJECTS = ROOT_PROJECTS.flat_map do |root|
    Dir.glob(File.join(root, '*'))
  end.freeze

  def initialize(command)
    @command = command
  end

  def projects
    PROJECTS.map { |path| path.chomp('/') }.compact.uniq
  end
end

puts ZshRecentDirectories.new(ENV['COMP_LINE']).projects
