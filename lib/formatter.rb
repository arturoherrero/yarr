module Formatter
  def bold(text)
    "\033[1m#{text}\e[0m"
  end

  def red(text)
    "\e[1;31m#{text}\e[0m"
  end
end
