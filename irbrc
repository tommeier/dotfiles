#!/usr/bin/ruby
puts "Loading ~/.irbrc settings..."
alias q exit

#Ruby console IRB helpful commands
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

%w[rubygems looksee/shortcuts wirble yaml].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

def source_for(object, method_sym)
  if object.respond_to?(method_sym, true)
    method = object.method(method_sym)
  elsif object.is_a?(Module)
    method = object.instance_method(method_sym)
  end
  location = method.source_location
  `code --goto #{location[0]}:#{location[1]}` if location
  location
rescue
  nil
end

#Colour Setup
ANSI_SETUP = {}
ANSI_SETUP[:RESET] = "\e[0m"
ANSI_SETUP[:BOLD] = "\e[1m"
ANSI_SETUP[:UNDERLINE] = "\e[4m"
ANSI_SETUP[:LGRAY] = "\e[0;37m"
ANSI_SETUP[:GRAY] = "\e[1;30m"
ANSI_SETUP[:RED] = "\e[31m"
ANSI_SETUP[:GREEN] = "\e[32m"
ANSI_SETUP[:YELLOW] = "\e[33m"
ANSI_SETUP[:BLUE] = "\e[34m"
ANSI_SETUP[:MAGENTA] = "\e[35m"
ANSI_SETUP[:CYAN] = "\e[36m"
ANSI_SETUP[:WHITE] = "\e[37m"

# Build a simple colorful IRB prompt
IRB.conf[:PROMPT][:SIMPLE_COLOR] = {
  :PROMPT_I => "#{ANSI_SETUP[:BLUE]}>>#{ANSI_SETUP[:RESET]} ",
  :PROMPT_N => "#{ANSI_SETUP[:BLUE]}>>#{ANSI_SETUP[:RESET]} ",
  :PROMPT_C => "#{ANSI_SETUP[:RED]}?>#{ANSI_SETUP[:RESET]} ",
  :PROMPT_S => "#{ANSI_SETUP[:YELLOW]}?>#{ANSI_SETUP[:RESET]} ",
  :RETURN => "#{ANSI_SETUP[:GREEN]}=>#{ANSI_SETUP[:RESET]} %s\n",
  :AUTO_INDENT => true }
IRB.conf[:PROMPT_MODE] = :SIMPLE_COLOR

# Loading extensions of the console. This is wrapped
# because some might not be included in your Gemfile
# and errors will be raised
def extend_console(name, care = true, required = true)
  if care
    require name if required
    yield if block_given?
    $console_extensions << "#{ANSI_SETUP[:GREEN]}#{name}#{ANSI_SETUP[:RESET]}"
  else
    $console_extensions << "#{ANSI_SETUP[:GRAY]}#{name}#{ANSI_SETUP[:RESET]}"
  end
rescue LoadError
  $console_extensions << "#{ANSI_SETUP[:RED]}#{name}#{ANSI_SETUP[:RESET]}"
end
$console_extensions = []

# Wirble is a gem that handles coloring the IRB
# output and history
extend_console 'wirble' do
  Wirble.init
  Wirble.colorize
end
#
# # Hirb makes tables easy.
extend_console 'hirb' do
  Hirb.enable
  extend Hirb::Console
end

# awesome_print is prints prettier than pretty_print
extend_console 'ap' do
  alias pp ap
end

# When you're using Rails 2 console, show queries in the console
extend_console 'rails2', (ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')), false do
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

# When you're using Rails 3 console, show queries in the console
extend_console 'rails3', defined?(ActiveSupport::Notifications), false do
  $odd_or_even_queries = false
  ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
    $odd_or_even_queries = !$odd_or_even_queries
    color = $odd_or_even_queries ? ANSI_SETUP[:CYAN] : ANSI_SETUP[:MAGENTA]
    event = ActiveSupport::Notifications::Event.new(*args)
    time = "%.1fms" % event.duration
    name = event.payload[:name]
    sql = event.payload[:sql].gsub("\n", " ").squeeze(" ")
    puts " #{ANSI_SETUP[:UNDERLINE]}#{color}#{name} (#{time})#{ANSI_SETUP[:RESET]} #{sql}"
  end
end

# Add a method pm that shows every method on an object
# Pass a regex to filter these
extend_console 'pm', true, false do
  def pm(obj, *options) # Print methods
    methods = obj.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = obj.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name.to_s, args, klass]
    end
    max_name = data.collect {|item| item[0].size}.max
    max_args = data.collect {|item| item[1].size}.max
    data.each do |item|
      print " #{ANSI_SETUP[:YELLOW]}#{item[0].to_s.rjust(max_name)}#{ANSI_SETUP[:RESET]}"
      print "#{ANSI_SETUP[:BLUE]}#{item[1].ljust(max_args)}#{ANSI_SETUP[:RESET]}"
      print " #{ANSI_SETUP[:GRAY]}#{item[2]}#{ANSI_SETUP[:RESET]}\n"
    end
    data.size
  end
end

extend_console 'interactive_editor' do
  # no configuration needed
end

# Show results of all extension-loading
puts "#{ANSI_SETUP[:GRAY]}~> Console extensions:#{ANSI_SETUP[:RESET]} #{$console_extensions.join(' ')}#{ANSI_SETUP[:RESET]}"
