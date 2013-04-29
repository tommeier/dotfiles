require 'simplecov'

SimpleCov.start do
  add_filter '/converage/'
  add_filter '/fixtures/'
  add_filter '/spec/'
end

ENV['TM_PROJECT_DIRECTORY'] ||= '.'

require 'stringio'
require 'rspec/mate'
require 'rspec/core'
