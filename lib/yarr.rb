require "io/console"
require "readline"

class YARR
  def call
    banner
    number = 0
    loop do
      number += 1
      expression = Readline.readline(prompt(number), true)
      break if expression == "exit"
      evaluate(expression)
    end
  end

  private

  def banner
    puts bold("YARR | Ruby #{RUBY_VERSION}")
    puts bold("-" * IO.console.winsize.last)
  end

  def prompt(n)
    "#{bold("ruby")}:#{"%03d" % n}#{bold(">")} "
  end

  def evaluate(expression)
    puts("#{bold("===>")} #{eval(expression, TOPLEVEL_BINDING)}")
  rescue Exception => e
    puts bold(red(e.message))
  end

  def bold(text)
    "\033[1m#{text}\e[0m"
  end

  def red(text)
    "\e[1;31m#{text}\e[0m"
  end
end

class NilClass
  def to_s
    "nil"
  end
end
