require "readline"
require "stringio"
require_relative "formatter"

class Interpreter
  include Formatter

  def initialize
    Readline.completion_append_character = nil
    Readline.completion_proc = lambda do |input|
      commands.grep(/^#{Regexp.escape(input)}/)
    end
  end

  def call
    separator = ">"
    expression = ""
    begin
      expression += Readline.readline(prompt(separator), false)
      Readline::HISTORY << expression
      capture_stdout { eval(expression, TOPLEVEL_BINDING) }
    rescue SyntaxError => e
      if e.message =~ /syntax error, unexpected end-of-input/
        Readline::HISTORY.pop
        expression += "\n       "
        separator = "*"
        retry
      end
    rescue Exception => e
    end
    process(expression)
  end

  private

  def prompt(separator)
    "#{bold('ruby')}:#{format('%03d', (Readline::HISTORY.size + 1))}#{bold(separator)} "
  end

  def process(expression)
    if expression.chr == ":"
      command(expression)
    else
      evaluate(expression)
    end
  end

  def command(expression)
    command, arguments = expression.split(" ", 2)
    send(command[1..-1], arguments)
  rescue StandardError
    "#{red('ERROR')} #{command} command is not available"
  end

  def exit(_args)
    exit!
  end
  alias_method :quit, :exit

  def help(_args)
    <<-END.gsub(/^\s+\|/, "")
    |
    |Available commands:
    |  #{bold(':exit')}    Exit the shell
    |  #{bold(':help')}    Display this help message
    |  #{bold(':hist')}    Display edit-line history
    |  #{bold(':quit')}    Alias to #{bold(':exit')}
    |  #{bold(':')}number  Execute a specific expression from history
    |  #{bold(':!')} cmd   Execute a shell command à la Vim
    |
    END
  end

  def hist(_args)
    "".tap do |history|
      Readline::HISTORY.to_a.each.with_index(1) do |command, index|
        history << "  #{bold('%03d' % index)}  #{command}\n"
      end
    end
  end

  define_method("!") do |args|
    `export CLICOLOR=1; export CLICOLOR_FORCE=1; #{args}`
  end

  def method_missing(name, *_args)
    index = (name.to_s[1..-1].to_i - 1).tap { |index| raise StandardError if index == -1 }
    expression = Readline::HISTORY[index]
    Readline::HISTORY.pop
    Readline::HISTORY << expression
    process(expression)
  end

  def evaluate(expression)
    "#{bold('===>')} #{eval(expression, TOPLEVEL_BINDING)}"
  rescue Exception => e
    "#{red('ERROR')} #{e.message}"
  end

  def commands
    %w[:exit :help :hist :quit :!]
  end

  def capture_stdout(&block)
    stdout = $stdout
    $stdout = StringIO.new
    block.call
  ensure
    $stdout = stdout
  end
end
