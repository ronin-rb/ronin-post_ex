require 'spec_helper'
require 'ronin/post_ex/sessions/reverse_shell'

describe Ronin::PostEx::Sessions::ReverseShell do
  it "must inherit from Ronin::PostEx::Sessions::RemoteShellSession" do
    expect(described_class).to be < Ronin::PostEx::Sessions::RemoteShellSession
  end

  let(:host)     { 'localhost' }
  let(:port)     { 1337 }
  let(:addrinfo) { Addrinfo.tcp(host,port) }

  describe ".listen" do
    let(:server_socket) { double('TCPServer') }
    let(:client_socket) { double('TCPSocket') }

    before  { allow(client_socket).to receive(:remote_address).and_return(addrinfo) }
    subject { described_class }

    it "must listen on a local port, accept a connection, return a #{described_class} object, and close the server socket" do
      expect(TCPServer).to receive(:new).with(port,nil).and_return(server_socket)
      expect(server_socket).to receive(:listen).with(1)
      expect(server_socket).to receive(:accept).and_return(client_socket)
      expect(server_socket).to receive(:close)

      reverse_shell = subject.listen(port)

      expect(reverse_shell).to be_kind_of(described_class)
      expect(reverse_shell.io).to be(client_socket)
    end

    context "and a host argument is given" do
      let(:host) { '127.0.0.1' }

      it "must listen on a local host and port, accept a connection, return a #{described_class} object, and close the server socket" do
        expect(TCPServer).to receive(:new).with(port,host).and_return(server_socket)
        expect(server_socket).to receive(:listen).with(1)
        expect(server_socket).to receive(:accept).and_return(client_socket)
        expect(server_socket).to receive(:close)
        allow(client_socket).to receive(:local_address).and_return(addrinfo)

        reverse_shell = subject.listen(host,port)

        expect(reverse_shell).to be_kind_of(described_class)
        expect(reverse_shell.io).to be(client_socket)
      end
    end
  end
end
