#!/usr/bin/env ruby

require 'bundler/setup'
require 'ronin/post_ex/sessions/bind_shell'
require 'ronin/post_ex/system'
require 'socket'

# run `nc -l -p 1337 -e /bin/sh` in another terminal
socket = begin
           TCPSocket.new('localhost',1337)
         rescue
           warn "Please run 'nc -l -p 1337 -e /bin/sh' in another terminal"
           exit(-1)
         end

session = Ronin::PostEx::Sessions::BindShell.new(socket)
system  = Ronin::PostEx::System.new(session)

system.interact
