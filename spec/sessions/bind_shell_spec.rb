require 'spec_helper'
require 'ronin/post_ex/sessions/bind_shell'

describe Ronin::PostEx::Sessions::BindShell do
  it "must inherit from Ronin::PostEx::Sessions::ShellSession" do
    expect(described_class).to be < Ronin::PostEx::Sessions::ShellSession
  end

  let(:host)     { 'example.com' }
  let(:port)     { 1337 }
  let(:addrinfo) { Addrinfo.tcp(host,port) }

  describe ".connect" do
    let(:host) { 'example.com' }
    let(:port) { 1337 }

    let(:socket) { double('TCPSocket') }

    subject { described_class }

    it "must connect to the remote host and port and return a #{described_class} object" do
      expect(TCPSocket).to receive(:new).with(host,port).and_return(socket)
      allow(socket).to receive(:local_address).and_return(addrinfo)

      bind_shell = subject.connect(host,port)

      expect(bind_shell).to be_kind_of(described_class)
      expect(bind_shell.io).to be(socket)
    end
  end

  let(:socket) { double('TCPSocket') }

  before  { allow(socket).to receive(:remote_address).and_return(addrinfo) }
  subject { described_class.new(socket) }

  describe "#initialize" do
    it "must set #io" do
      expect(subject.io).to be(socket)
    end

    let(:ip) { addrinfo.ip_address }

    it "musst set #name to \"ip:port\"" do
      expect(subject.name).to eq("#{ip}:#{port}")
    end
  end
end
