require "io/console"
require "readline"

class YARR
  def initialize
    Readline.completion_append_character = nil
    Readline.completion_proc = lambda do |input|
      commands.grep(/^#{Regexp.escape(input)}/)
    end
  end

  def call
    banner
    number = 0
    loop do
      number += 1
      separator = ">"
      expression = ""
      begin
        expression += Readline.readline(prompt(number, separator), false)
        Readline::HISTORY << expression
        eval(expression, TOPLEVEL_BINDING)
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
  end

  private

  def banner
    puts bold("YARR | Ruby #{RUBY_VERSION}")
    puts "Type '#{bold(":help")}' for help."
    puts bold("-" * IO.console.winsize.last)
  end

  def prompt(n, separator)
    "#{bold("ruby")}:#{"%03d" % n}#{bold(separator)} "
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
    self.send(command[1..-1], arguments)
  rescue
    puts "#{red("ERROR")} #{command} command is not available"
  end

  def exit(args)
    exit!
  end
  alias_method :quit, :exit

  def help(args)
    puts
    puts "Available commands:"
    puts "  #{bold(":exit")}   Exit the shell"
    puts "  #{bold(":help")}   Display this help message"
    puts "  #{bold(":hist")}   Display edit-line history"
    puts "  #{bold(":quit")}   Alias to #{bold(":exit")}"
    puts "  #{bold(":!")} cmd  Execute a shell command à la Vim"
    puts
  end

  def hist(args)
    Readline::HISTORY.to_a.each.with_index(1) do |command, index|
      puts "  #{bold("%03d" % index)}  #{command}"
    end
  end

  define_method("!") do |args|
    puts `#{args}`
  end

  def evaluate(expression)
    puts "#{bold("===>")} #{eval(expression, TOPLEVEL_BINDING)}"
  rescue Exception => e
    puts "#{red("ERROR")} #{e.message}"
  end

  def bold(text)
    "\033[1m#{text}\e[0m"
  end

  def red(text)
    "\e[1;31m#{text}\e[0m"
  end

  def commands
    %w(:exit :help :hist :quit :!)
  end
end

class NilClass
  def to_s
    "nil"
  end
end
