# frozen_string_literal: true
#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# ronin-post_ex is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-post_ex is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-post_ex.  If not, see <https://www.gnu.org/licenses/>.
#

require_relative 'resource'
require_relative 'system/fs'
require_relative 'system/process'
require_relative 'system/shell'
require_relative 'cli/system_shell'

module Ronin
  module PostEx
    #
    # Represents a successfully compromised system. The {System} class will
    # wraps around a session object which defines syscall-like post-exploitation
    # API for reading/writing files, run commands, etc.
    #
    # ## Supported API Functions
    #
    # * `sys_time -> Integer`
    # * `sys_hostname -> String`
    #
    # ## Example
    #
    # Define the session class which defines the Post-Exploitation Session API
    # methods:
    #
    #     require 'ronin/post_ex/sessions/session'
    #     require 'base64'
    #     
    #     class MyRatSession < Ronin::PostEx::Sessions::Session
    #
    #       def initialize(socket)
    #         @socket = socket
    #       end
    #     
    #       def send_command(name,*args)
    #         # send the command line
    #         @socket.puts("#{name} #{args.join(' ')}")
    #
    #         # read and Base64 decode the response line
    #         Base64.strict_decode64(@socket.gets(chomp: true))
    #       end
    #
    #       def shell_exec(command)
    #         send_command('EXEC',command)
    #       end
    #
    #       def fs_readfile(path)
    #         send_command('READ',path)
    #       end
    #
    #       def process_pid
    #         send_command('PID').to_i
    #       end
    #
    #       def process_getuid
    #         send_command('UID').to_i
    #       end
    #
    #       def process_environ
    #         Hash[
    #           send_command('ENV').each_line(chomp: true).map { |line|
    #             line.split('=',2)
    #           }
    #         ]
    #       end
    #
    #     end
    #
    # Initialize a new {System} object that wraps around the client:
    #
    #     session = MyRatSession.new(socket)
    #     system  = Ronin::PostEx::System.new(session)
    #
    # Interact with the system's remote files as if they were local files:
    #
    #     file = system.fs.open('/etc/passwd')
    #     file.each_line do |line|
    #       user, x, uid, gid, name, home_dir, shell = line.split(':')
    #
    #       puts "User Detected: #{user} (id=#{uid})"
    #     end
    #
    # Get information about the current process:
    #
    #     system.process.pid
    #     # => 1234
    #     system.process.getuid
    #     # => 1001
    #     system.process.environ
    #     # => {"HOME"=>"...", "PATH"=>"...", ...}
    #
    # Execute commands on the remote system:
    #
    #     system.shell.ls('/')
    #     # => "bin\nboot\ndev\netc\nhome\nlib\nlib64\nlost+found\nmedia\nmnt\nopt\nproc\nroot\nrun\nsbin\nsnap\nsrv\nsys\ntmp\nusr\nvar\n"
    #     system.shell.exec("find -type f -name '*.xls' /srv") do |path|
    #       puts "Found XLS file: #{path}"
    #     end
    #
    class System < Resource

      # The File-System resource.
      #
      # @return [System::FS]
      attr_reader :fs

      # The Process resource.
      #
      # @return [System::Process]
      attr_reader :process

      # The Shell resource.
      #
      # @return [System::Shell]
      attr_reader :shell

      #
      # Initializes the system.
      #
      # @param [Object] session
      #   The object which defines the Post-Exploitation API methods.
      #
      def initialize(session)
        super(session)

        @fs      = FS.new(session)
        @process = Process.new(session)
        @shell   = Shell.new(session)
      end

      #
      # Gets the current time.
      #
      # @return [Time]
      #   The current time.
      #
      # @note
      #   Requires the `sys_time` method be defined by the {#session} object.
      #
      def time
        Time.at(@session.sys_time.to_i)
      end
      resource_method :time, [:sys_time]

      #
      # Gets the system's hostname.
      #
      # @return [String]
      #   The system's local hostname.
      #
      # @note
      #   Requires the `sys_hostname` method be defined by the {#session}
      #   object.
      #
      def hostname
        @session.sys_hostname
      end

      #
      # Starts an interactive post-exploitation system shell.
      #
      def interact
        CLI::SystemShell.start(self)
      end

      #
      # Exits the process.
      #
      # @see Process#exit
      #
      def exit
        @process.exit
      end

    end
  end
end
