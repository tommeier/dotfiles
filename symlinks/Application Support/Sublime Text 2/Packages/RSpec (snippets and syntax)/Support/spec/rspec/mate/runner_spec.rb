require 'spec_helper'
require 'stringio'

describe RSpec::Mate::Runner do
  before(:each) do
    # TODO: long path
    @first_failing_spec  = /fixtures\/example_failing_spec\.rb&line=3/n
    @second_failing_spec = /fixtures\/example_failing_spec\.rb&line=7/n

    set_env

    load File.expand_path(
      # TODO: long path
      "#{File.dirname(__FILE__)}/../../../lib/rspec/mate.rb"
    )

    @spec_mate = RSpec::Mate::Runner.new
    @test_runner_io = StringIO.new
  end

  after(:each) do
    set_env

    $".delete_if do |path|
      path =~ /example_failing_spec\.rb/
    end
  end

  describe "#run" do
    it "shows a nicely formatted error when there's an uncaught exception" do
      ENV['TM_FILEPATH'] = fixtures_path('example_syntax_error_spec.rb')

      @spec_mate.run_file(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ /Uncaught Exception/
      html.should_not =~ /^  .%<.*$/
    end

    it "shows standard error output nicely in a PRE block" do
      ENV['TM_FILEPATH'] = fixtures_path('example_stderr_spec.rb')

      @spec_mate.run_file(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ /#{Regexp.escape("<h2>stderr:</h2><pre>2 + 2 = 4\n4 &lt; 8\n</pre>")}/
    end
  end

  describe "#run_file" do
    it "runs whole file when only file specified" do
      ENV['TM_FILEPATH'] = fixtures_path('example_failing_spec.rb')

      @spec_mate.run_file(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ @first_failing_spec
      html.should =~ @second_failing_spec
    end
  end

  describe "#run_files" do
    it "runs all selected files" do
      fixtures = [
        'example_failing_spec.rb',
        'example_passing_spec.rb'
      ]

      # TODO: adjust fixtures_path to take an array
      ENV['TM_SELECTED_FILES'] = fixtures.map do |fixture|
        "'#{fixtures_path(fixture)}'"
      end.join(" ")

      @spec_mate.run_files(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ @first_failing_spec
      html.should =~ @second_failing_spec
      html.should =~ /should pass/
      html.should =~ /should pass too/
    end
  end

  describe "#run_last_remembered_file" do
    it "runs all of the selected files" do
      @spec_mate.save_as_last_remembered_file fixtures_path('example_failing_spec.rb')
      @spec_mate.run_last_remembered_file(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ @first_failing_spec
    end
  end

  describe "#run_focused" do
    it "runs first spec when file and line 4 specified" do
      ENV['TM_FILEPATH'] = fixtures_path('example_failing_spec.rb')
      ENV['TM_LINE_NUMBER'] = '4'

      @spec_mate.run_focussed(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should =~ @first_failing_spec
      html.should_not =~ @second_failing_spec
    end

    it "runs first spec when file and line 8 specified" do
      ENV['TM_FILEPATH'] = fixtures_path('example_failing_spec.rb')
      ENV['TM_LINE_NUMBER'] = '8'

      @spec_mate.run_focussed(@test_runner_io)
      @test_runner_io.rewind
      html = @test_runner_io.read

      html.should_not =~ @first_failing_spec
      html.should =~ @second_failing_spec
    end
  end

  describe "error cases" do
    it "raises an exception when TM_PROJECT_DIRECTORY points to bad location" do
      ENV['TM_PROJECT_DIRECTORY'] = __FILE__ # bad on purpose

      lambda do
        # TODO: long path
        load File.dirname(__FILE__) + '/../../../lib/rspec/mate.rb'
      end.should_not raise_error
    end

    it "raises an exception when TM_RSPEC_HOME points to bad location" do
      ENV['TM_RSPEC_HOME'] = __FILE__ # bad on purpose

      lambda do
        load File.dirname(__FILE__) + '/../lib/rspec_mate.rb'
      end.should raise_error
    end
  end

  describe "alternative formatter" do
    it "adds a custom formatter to the command if TM_RSPEC_FORMATTER is set" do
      ENV['TM_RSPEC_FORMATTER'] = 'RSpec::Core::Formatters::BaseTextFormatter'
      ENV['TM_FILEPATH'] = fixtures_path('example_failing_spec.rb')

      @spec_mate.run_file(@test_runner_io)
      @test_runner_io.rewind
      text = @test_runner_io.read

      text.should =~ /1\) An example failing spec should fail/
      text.should =~ /2\) An example failing spec should also fail/
    end
  end


private

  def fixtures_path(fixture)
    # TODO: long path
    fixtures_path = File.expand_path(
      File.dirname(__FILE__)
    ) + '/../../../fixtures'

    File.join(fixtures_path, fixture)
  end

  def set_env
    # TODO: long path
    root = File.expand_path('../../../../../../rspec-core', __FILE__)

    ENV['TM_FILEPATH']          = nil
    ENV['TM_LINE_NUMBER']       = nil
    ENV['TM_PROJECT_DIRECTORY'] = File.expand_path(File.dirname(__FILE__))
    ENV['TM_RSPEC_HOME']        = "#{root}"
  end
end
