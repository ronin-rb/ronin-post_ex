#!/usr/bin/env ruby

require 'bundler/setup'
require 'ronin/post_ex/sessions/shell_session'
require 'ronin/post_ex/system'
require 'socket'

# run `nc -l -p 1337 -e /bin/sh` in another terminal
socket = TCPSocket.new('localhost',1337)

session = Ronin::PostEx::Sessions::ShellSession.new(socket)
system  = Ronin::PostEx::System.new(session)

system.interact
