# coding:utf-8 vim:ft=ruby

Pry.config.pager = false
Pry.config.color = true
Pry.config.should_load_local_rc = Dir.pwd != Dir.home

require 'readline'
if Readline::VERSION =~ /editline/i
  warn "Warning: Using Editline instead of Readline."
end

# wrap ANSI codes so Readline knows where the prompt ends
def colour(name, text)
  if Pry.color
    "\001#{Pry::Helpers::Text.send name, '{text}'}\002".sub '{text}', "\002#{text}\001"
  else
    text
  end
end

# pretty prompt
Pry.config.prompt = [
  proc { |target_self, nest_level, pry|
    prompt = colour :bright_black, Pry.view_clip(target_self)
    prompt += ":#{nest_level}" if nest_level > 0
    prompt += colour :cyan, ' » '
  },
  proc { |target_self, nest_level, pry|
    colour :red, '?> '
  }
]

# tell Readline when the window resizes
old_winch = trap 'WINCH' do
  if `stty size` =~ /\A(\d+) (\d+)\n\z/
    Readline.set_screen_size $1.to_i, $2.to_i
  end
  old_winch.call unless old_winch.nil? || old_winch == 'SYSTEM_DEFAULT'
end

# use awesome print for output if available
org_print = Pry.config.print
Pry.config.print = proc do |output, value, _pry_|
  begin
    require 'awesome_print'
    case
    when defined?(Capybara) && value.is_a?(Capybara::Node::Element)
      org_print.call(output, value, _pry_)
    when defined?(ActiveSupport::SafeBuffer) && value.is_a?(ActiveSupport::SafeBuffer)
      output.print value.to_str.ai
      if value.html_safe?
        output.print ' (HTML safe)'
      end
      output.puts
    when defined?(Heroics) && value.is_a?(Heroics::Client)
      output.puts value.instance_variable_get('@resources').keys.ai(multiline: false)
    when defined?(Heroics) && value.is_a?(Heroics::Resource)
      output.puts value.instance_variable_get('@links').keys.ai(multiline: false)
    else
      value = value.to_a if %w[ActiveRecord::Relation ActiveRecord::Result].include?(value.class.name)
      output.puts value.ai
    end
  rescue LoadError => err
    org_print.call(output, value, _pry_)
  end
  Pry.history.save if Pry.history.respond_to? :save
end

org_logger_active_record = nil
org_logger_rails = nil

Pry.hooks.add_hook :before_session, :rails do |output, target, pry|
  require 'logger'
  new_logger = Logger.new(STDOUT)
  if defined?(ActiveSupport::TaggedLogging)
    new_logger = ActiveSupport::TaggedLogging.new(new_logger)
  end

  # show ActiveRecord SQL queries in the console
  if defined? ActiveRecord
    org_logger_active_record = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = new_logger
  end

  if defined?(Rails) && Rails.env
    # output all other log info such as deprecation warnings to the console
    if Rails.respond_to? :logger=
      org_logger_rails = Rails.logger
      Rails.logger = new_logger
    end

    # load Rails console commands
    if Rails::VERSION::MAJOR >= 3
      require 'rails/console/app'
      require 'rails/console/helpers'
      if Rails.const_defined? :ConsoleMethods
        extend Rails::ConsoleMethods
      end
    else
      require 'console_app'
      require 'console_with_helpers'
    end
  end
end

Pry.hooks.add_hook :after_session, :rails do |output, target, pry|
  ActiveRecord::Base.logger = org_logger_active_record if org_logger_active_record
  Rails.logger = org_logger_rails if org_logger_rails
end

def pbcopy(data)
  IO.popen 'pbcopy', 'w' do |io|
    io << data
  end
  nil
end

def pbpaste
  `pbpaste`
end
