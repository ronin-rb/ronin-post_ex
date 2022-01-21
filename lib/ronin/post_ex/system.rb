#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-post_ex.
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

require 'ronin/post_ex/resources'

module Ronin
  module PostEx
    #
    # Represents an successfully compromised system. The {System} class will
    # wraps around another object which defines syscall-like Post-Exploitation
    # API to read/write files, run commands, etc.
    #
    # ## Example
    #
    # Define the client which defines the Post-Exploitation API methods:
    #
    #     class RATClient
    #     
    #       # ...
    #     
    #       def fs_read(path)
    #         rpc_call("fs_read",path)
    #       end
    #     
    #       def shell_exec(command)
    #         rpc_call("shell_exec",command)
    #       end
    #
    #       # ...
    #     
    #     end
    #
    # Initialize a new {System} object that wraps around the client:
    #
    #     rat_client = RATClient.new(host,port)
    #     system = Ronin::PostEx::System.new(rat_client)
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
    class System

      # The object which defines the Post-Exploitation API methods.
      #
      # @return [Object]
      attr_reader :api

      # The File-System resource.
      #
      # @return [Resources::FS]
      attr_reader :fs

      # The Process resource.
      #
      # @return [Resources::Process]
      attr_reader :process

      # The Shell resource.
      #
      # @return [Resources::Shell]
      attr_reader :shell

      #
      # Initializes the system.
      #
      # @param [Object] api
      #   The object which defines the Post-Exploitation API methods.
      #
      def initialize(api)
        @api = api

        @fs      = Resources::FS.new(@api)
        @process = Resources::Process.new(@api)
        @shell   = Resources::Shell.new(@api)
      end

    end
  end
end
