require 'spec_helper'
require 'ronin/post_ex/sessions/shell_session'

require 'socket'

describe Ronin::PostEx::Sessions::ShellSession do
  let(:pipe)  { UNIXSocket.pair }
  let(:io)    { pipe[0] }
  let(:shell) { pipe[1] }

  subject { described_class.new(io) }

  describe "#initialize" do
    it "must set #io" do
      expect(subject.io).to be(io)
    end
  end

  describe "#shell_exec" do
    let(:command) { 'ls' }
    let(:output) do
      [
        "API_SPEC.md",
        "ChangeLog.md",
        "COPYING.txt",
        "Gemfile",
        "Gemfile.lock",
        "gemspec.yml",
        "lib",
        "Rakefile",
        "README.md",
        "ronin-post_ex.gemspec",
        "spec",
        "vendor"
      ].map { |line| "#{line}\n" }.join
    end

    it "must print a beginning deliminator, pipe the command into base64, and print an ending deliminator" do
      thread = Thread.new do
        sleep 0.1
        subject.shell_exec(command)
      end

      expect(shell.gets).to eq("echo #{described_class::DELIMINATOR}; #{command} 2>/dev/null | base64; echo #{described_class::DELIMINATOR}\n")
      shell.puts(described_class::DELIMINATOR)
      shell.write(Base64.encode64(output))
      shell.puts(described_class::DELIMINATOR)
    end

    it "must return the output of the command" do
      thread = Thread.new do
        sleep 0.1

        shell.gets
        shell.puts(described_class::DELIMINATOR)
        shell.write(Base64.encode64(output))
        shell.puts(described_class::DELIMINATOR)
      end

      expect(subject.shell_exec(command)).to eq(output)
    end
  end

  describe "#close" do
    it "must call #close on #io" do
      expect(io).to receive(:close)

      subject.close
    end
  end
end
