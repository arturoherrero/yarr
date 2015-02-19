require "io/console"
require_relative "formatter"
require_relative "interpreter"

class YARR
  include Formatter

  def initialize(args = {})
    $stdout.sync = true
    @interpreter = args.fetch(:interpreter) { Interpreter.new }
  end

  def call
    banner
    loop do
      puts interpreter.call
    end
  end

  private

  attr_reader :interpreter

  def banner
    puts bold("YARR | Ruby #{RUBY_VERSION}")
    puts "Type '#{bold(":help")}' for help."
    puts bold("-" * IO.console.winsize.last)
  end
end

class NilClass
  def to_s
    "nil"
  end
end
