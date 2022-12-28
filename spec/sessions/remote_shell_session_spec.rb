require 'spec_helper'
require 'ronin/post_ex/sessions/bind_shell'

describe Ronin::PostEx::Sessions::BindShell do
  it "must inherit from Ronin::PostEx::Sessions::ShellSession" do
    expect(described_class).to be < Ronin::PostEx::Sessions::ShellSession
  end

  let(:host)     { 'example.com' }
  let(:port)     { 1337 }
  let(:addrinfo) { Addrinfo.tcp(host,port) }
  let(:socket)   { double('TCPSocket') }

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
