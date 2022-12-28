require 'spec_helper'
require 'ronin/post_ex/sessions/bind_shell'

describe Ronin::PostEx::Sessions::BindShell do
  it "must inherit from Ronin::PostEx::Sessions::RemoteShellSession" do
    expect(described_class).to be < Ronin::PostEx::Sessions::RemoteShellSession
  end

  let(:host)     { 'example.com' }
  let(:port)     { 1337 }
  let(:addrinfo) { Addrinfo.tcp(host,port) }

  describe ".connect" do
    let(:host) { 'example.com' }
    let(:port) { 1337 }

    let(:socket) { double('TCPSocket') }

    before  { allow(socket).to receive(:remote_address).and_return(addrinfo) }
    subject { described_class }

    it "must connect to the remote host and port and return a #{described_class} object" do
      expect(TCPSocket).to receive(:new).with(host,port).and_return(socket)

      bind_shell = subject.connect(host,port)

      expect(bind_shell).to be_kind_of(described_class)
      expect(bind_shell.io).to be(socket)
    end
  end
end
