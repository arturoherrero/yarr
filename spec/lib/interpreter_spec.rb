require "interpreter"

RSpec.describe Interpreter do
  subject(:interpreter) { described_class.new }

  it "executes simple expression" do
    given("1")
    expect(interpreter.call).to eq("\e[1m===>\e[0m 1")
  end

  it "executes one line expression" do
    given("1 + 1")
    expect(interpreter.call).to eq("\e[1m===>\e[0m 2")
  end

  it "executes multiline line declaration" do
    given("def foo", "1", "end")
    expect(interpreter.call).to eq("\e[1m===>\e[0m foo")
  end

  it "executes multiline line declaration and invocation" do
    setup("def foo", "1", "end")
    given("foo")
    expect(interpreter.call).to eq("\e[1m===>\e[0m 1")
  end

  describe ":hist" do
    it "shows the history" do
      setup("5")
      setup("def foo", "1", "end")
      setup("foo")
      given(":hist")
      expect(interpreter.call).to eq(<<-END.gsub(/^\s+\||$/, '')
        |  \e[1m001\e[0m  5
        |  \e[1m002\e[0m  def foo
        |       1
        |       end
        |  \e[1m003\e[0m  foo
        |  \e[1m004\e[0m  :hist
        END
      )
    end
  end

  describe ":number" do
    it "executes an expression from history" do
      setup("var = 5")
      setup("var = 0")
      given(":001")
      expect(interpreter.call).to eq("\e[1m===>\e[0m 5")
    end

    it "adds the command to the history" do
      setup("var = 5")
      setup("var = 0")
      setup(":001")
      given(":hist")
      expect(interpreter.call).to eq(<<-END.gsub(/^\s+\||$/, '')
        |  \e[1m001\e[0m  var = 5
        |  \e[1m002\e[0m  var = 0
        |  \e[1m003\e[0m  var = 5
        |  \e[1m004\e[0m  :hist
        END
      )
    end
  end

  describe ":! cmd" do
    let(:output) { "-rw-r--r--  1 arturo  staff    39 16 Feb 21:11 spec.rb" }
    before do
      allow(interpreter).to receive(:'`').with("ls -l").and_return(output)
    end

    it "executes an external shell command" do
      given(":! ls -l")
      expect(interpreter.call).to eq(output)
    end
  end

  context "invalid expression" do
    it "returns a syntax error" do
      given("1 + &")
      expect(interpreter.call).to eq(<<-END.gsub(/^\s+\||\n$/, '')
        |\e[1;31mERROR\e[0m <main>: syntax error, unexpected &
        |1 + &
        |     ^
        END
      )
    end
  end

  context "invalid command" do
    it "returns a command error" do
      given(":invalid")
      expect(interpreter.call).to eq("\e[1;31mERROR\e[0m :invalid command is not available")
    end
  end

  private

  def setup(*input)
    given(*input)
    interpreter.call
  end

  def given(*input)
    allow(Readline).to receive(:readline).and_return(*input)
  end

  after(:each) do
    Readline::HISTORY.clear
  end
end
