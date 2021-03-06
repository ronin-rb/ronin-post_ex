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

require 'ronin/post_ex/resource'
require 'ronin/post_ex/remote_command'
require 'ronin/post_ex/cli/shell_shell'

require 'date'

module Ronin
  module PostEx
    class System < Resource
      #
      # Provides access to an interactive shell and executing shell commands.
      #
      # ## Supported API Methods
      #
      # * `shell_exec(program : String, *arguments : Array[String]) { |data : String| ... }`
      # * `shell_write(data : String)`
      #
      class Shell < Resource

        attr_reader :paths

        #
        # Initializes the Shell resource.
        #
        # @param [#shell_exec] api
        #   The API object that defines the `shell_exec` method.
        #
        def initialize(api)
          super(api)

          @paths = {}
        end

        #
        # Creates a command to later execute.
        #
        # @param [String] program
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @return [RemoteCommand]
        #   The newly created command.
        #
        def command(program,*arguments)
          program = (@paths[program.scan(/^[^\s]+/).first] || program)

          return RemoteCommand.new(@api,program,*arguments)
        end
        resource_method :command, [:shell_exec]

        #
        # Executes a command and reads the resulting output.
        #
        # @param [String] program
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @yield [line]
        #   If a block is given, it will be passed each line of output
        #   from the command.
        #
        # @yieldparam [String] line
        #   A line of output from the command.
        #
        # @return [String, nil]
        #   If no block is given, the full output of the command will be
        #   returned.
        #
        def exec(program,*arguments)
          cmd = command(program,*arguments)

          if block_given?
            cmd.each { |line| yield line.chomp }
          else
            cmd.read
          end
        end
        resource_method :exec, [:shell_exec]

        #
        # Executes a command and prints the resulting output.
        #
        # @param [String] command
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @return [nil]
        #
        def system(command,*arguments)
          exec(command,*arguments) { |line| puts line }
        end
        resource_method :system, [:shell_exec]

        #
        # Changes the current working directory in the shell.
        #
        # @param [String] path
        #   The path for the new current working directory.
        #
        # @return [String]
        #   Any error messages.
        #
        def cd(path)
          command('cd',path).first
        end
        resource_method :cd, [:shell_exec]

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        def pwd
          exec('pwd').chomp
        end
        resource_method :pwd, [:shell_exec]

        #
        # Lists the files or directories.
        #
        # @param [Array<String>] arguments
        #   Arguments to pass to the `ls` command.
        #
        # @see #exec
        #
        def ls(*arguments,&block)
          exec('ls',*arguments,&block)
        end
        resource_method :ls, [:shell_exec]

        #
        # Lists all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -a` command.
        #
        # @see #exec
        #
        def ls_a(*arguments,&block)
          exec('ls','-a',*arguments,&block)
        end
        resource_method :ls_a, [:shell_exec]

        #
        # Lists information about files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -l` command.
        #
        # @see #exec
        #
        def ls_l(*arguments,&block)
          exec('ls','-l',*arguments,&block)
        end
        resource_method :ls_l, [:shell_exec]

        #
        # Lists information about all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -la` command.
        #
        # @see #exec
        #
        def ls_la(*arguments,&block)
          exec('ls','-la',*arguments,&block)
        end
        resource_method :ls_la, [:shell_exec]

        alias ls_al ls_la

        #
        # Searches for files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `find` command.
        #
        # @yield [path]
        #   If a block is given, it will be passed each path found.
        #
        # @yieldparam [String] path
        #   A path found by the `find` command.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all found paths will be returned.
        #
        def find(*arguments)
          if block_given?
            exec('find',*arguments) { |line| yield line.chomp }
          else
            enum_for(__method__,*arguments).to_a
          end
        end
        resource_method :find, [:shell_exec]

        #
        # Determines the format of a file.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `file` command.
        #
        # @return [String]
        #   The output of the `file` command.
        #
        # @example
        #   exploit.shell.file('data.db')
        #   # => "data.db: SQLite 3.x database"
        #
        def file(*arguments)
          command('file',*arguments).first
        end
        resource_method :file, [:shell_exec]

        #
        # Finds a program available to the shell.
        #
        # @param [Array<String>] arguments
        #   Additional arguments ot pass to the `which` command.
        #
        # @return [String]
        #   The output from the `which` command.
        #
        def which(*arguments)
          command('which',*arguments).first
        end
        resource_method :which, [:shell_exec]

        #
        # Reads the contents of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cat` command.
        #
        # @see #exec
        #
        def cat(*arguments,&block)
          exec('cat',*arguments,&block)
        end
        resource_method :cat, [:shell_exec]

        #
        # Reads the first `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `head` command.
        #
        # @see #exec
        #
        def head(*arguments,&block)
          exec('head',*arguments,&block)
        end
        resource_method :head, [:shell_exec]

        #
        # Reads the first `n` lines of one or more files.
        #
        # @param [Integer] lines
        #   The number of lines to read from one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `head` command.
        #
        # @see #exec
        #
        def head_n(lines,*arguments,&block)
          head('-n',lines,*arguments,&block)
        end
        resource_method :head_n, [:shell_exec]

        #
        # Reads the last `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `tail` command.
        #
        # @see #exec
        #
        def tail(*arguments,&block)
          exec('tail',*arguments,&block)
        end
        resource_method :tail, [:shell_exec]

        #
        # Reads the last `n` lines of one or more files.
        #
        # @param [Integer] lines
        #   The number of lines to read from one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `tail` command.
        #
        # @see #exec
        #
        def tail_n(lines,*arguments,&block)
          tail('-n',lines,*arguments,&block)
        end
        resource_method :tail_n, [:shell_exec]

        #
        # Searches one or more files for a given pattern.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `grep` command.
        #
        # @yield [path, line]
        #   If a block is given, it will be passed the paths and lines
        #   within files that matched the given pattern.
        #
        # @yieldparam [String] path
        #   The path of a file that contains matching lines.
        #
        # @yieldparam [String] line
        #   A line that matches the given pattern.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all matching paths and lines will be
        #   returned.
        #
        def grep(*arguments,&block)
          if block_given?
            exec('grep',*arguments) do |line|
              yield(*line.split(':',2))
            end
          else
            enum_for(__method__,*arguments).to_a
          end
        end
        resource_method :grep, [:shell_exec]

        #
        # Runs `grep -E`.
        #
        # @see #grep
        #
        def egrep(*arguments,&block)
          grep('-E',*arguments,&block)
        end
        resource_method :egrep, [:shell_exec]

        #
        # Runs `grep -F`.
        #
        # @see #grep
        #
        def fgrep(*arguments,&block)
          grep('-F',*arguments,&block)
        end
        resource_method :fgrep, [:shell_exec]

        #
        # Touches a file.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `touch` command.
        #
        # @return [String]
        #   Any error messages returned by the `touch` command.
        #
        def touch(*arguments)
          command('touch',*arguments).first
        end
        resource_method :touch, [:shell_exec]

        #
        # Creates a tempfile.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to `mktemp`.
        #
        # @return [String]
        #   The path of the new tempfile.
        #
        def mktemp(*arguments)
          command('mktemp',*arguments).first.chomp
        end
        resource_method :mktemp, [:shell_exec]

        #
        # Creates a tempdir.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to `mktemp`.
        #
        # @return [String]
        #   The path of the new tempdir.
        #
        def mktempdir(*arguments)
          mktemp('-d',*arguments)
        end
        resource_method :mktempdir, [:shell_exec]

        #
        # Creates a new directory.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `mkdir` command.
        #
        # @return [String]
        #   Any error messages returned by the `mkdir` command.
        #
        def mkdir(*arguments)
          command('mkdir',*arguments).first
        end
        resource_method :mkdir, [:shell_exec]

        #
        # Copies one or more files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cp` command.
        #
        # @return [String]
        #   Any error messages returned by the `cp` command.
        #
        def cp(*arguments)
          command('cp',*arguments).first
        end
        resource_method :cp, [:shell_exec]

        #
        # Runs `cp -r`.
        #
        # @see #cp
        #
        def cp_r(*arguments)
          cp('-r',*arguments)
        end
        resource_method :cp_r, [:shell_exec]

        #
        # Runs `cp -a`.
        #
        # @see #cp
        #
        def cp_a(*arguments)
          cp('-a',*arguments)
        end
        resource_method :cp_a, [:shell_exec]

        #
        # Runs `rsync`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rsync` command.
        #
        # @see #exec
        #
        def rsync(*arguments,&block)
          exec('rsync',*arguments,&block)
        end
        resource_method :rsync, [:shell_exec]

        #
        # Runs `rsync -a`.
        #
        # @see #rsync
        #
        def rsync_a(*arguments,&block)
          rsync('-a',*arguments,&block)
        end
        resource_method :rsync_a, [:shell_exec]

        #
        # Runs `wget`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rsync` command.
        #
        # @see #exec
        #
        def wget(*arguments)
          exec('wget','-q',*arguments)
        end
        resource_method :wget, [:shell_exec]

        #
        # Runs `wget -O`.
        #
        # @param [String] path
        #   The path that `wget` will write to.
        #
        # @see #wget
        #
        def wget_out(path,*arguments)
          wget('-O',path,*arguments)
        end
        resource_method :wget_out, [:shell_exec]

        #
        # Runs the `curl`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `curl` command.
        #
        # @see #exec
        #
        def curl(*arguments)
          exec('curl','-s',*arguments)
        end
        resource_method :curl, [:shell_exec]

        #
        # Runs `curl -O`.
        #
        # @param [String] path
        #   The path that `curl` will write to.
        #
        # @see #curl
        #
        def curl_out(path,*arguments)
          curl('-O',path,*arguments)
        end
        resource_method :curl_out, [:shell_exec]

        #
        # Removes a directory.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rmdir` command.
        #
        # @return [String]
        #   Any error messages returned by the `rmdir` command.
        #
        def rmdir(*arguments)
          command('rmdir',*arguments).first
        end
        resource_method :rmdir, [:shell_exec]

        #
        # Removes one or more files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rm` command.
        #
        # @see #exec
        #
        def rm(*arguments,&block)
          exec('rm',*arguments,&block)
        end
        resource_method :rm, [:shell_exec]

        #
        # Runs `rm -r`.
        #
        # @see #rm
        #
        def rm_r(*arguments,&block)
          rm('-r',*arguments,&block)
        end
        resource_method :rm_r, [:shell_exec]

        #
        # Runs `rm -rf`.
        #
        # @see #rm
        #
        def rm_rf(*arguments,&block)
          rm('-rf',*arguments,&block)
        end
        resource_method :rm_rf, [:shell_exec]

        #
        # Gets the current time and date from the shell.
        #
        # @return [Date]
        #   The current data returned by the shell.
        #
        def date
          Date.parse(exec('date'))
        end
        resource_method :date, [:shell_exec]

        #
        # Gets the current time from the shell.
        #
        # @return [Time]
        #   The current time returned by the shell.
        #
        def time
          date.to_time
        end
        resource_method :time, [:shell_exec]

        #
        # The ID information of the current user.
        #
        # @return [Hash{Symbol => String}]
        #   The ID information returned by the `id` command.
        #
        def id
          hash = {}

          exec('id').split(' ').each do |name_value|
            name, value = name_value.split('=',2)

            hash[name.to_sym] = value
          end

          return hash
        end
        resource_method :id, [:shell_exec]

        #
        # The UID of the current user.
        #
        # @return [Integer]
        #   The UID of the current user.
        #
        def uid
          exec('id','-u').to_i
        end
        resource_method :uid, [:shell_exec]

        #
        # The GID of the current user.
        #
        # @return [Integer]
        #   The GID of the current user.
        #
        def gid
          exec('id','-g').to_i
        end
        resource_method :gid, [:shell_exec]

        #
        # The name of the current user.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `whoami` command.
        #
        # @return [String]
        #   The name of the current user returned by the `whoami` command.
        #
        def whoami(*arguments)
          exec('whoami',*arguments).chomp
        end
        resource_method :whoami, [:shell_exec]

        #
        # Shows who is currently logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `who` command.
        #
        # @see #exec
        #
        def who(*arguments,&block)
          exec('who',*arguments,&block)
        end
        resource_method :who, [:shell_exec]

        #
        # Similar to {#who} but runs the `w` command.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `w` command.
        #
        # @see #exec
        #
        def w(*arguments,&block)
          exec('w',*arguments,&block)
        end
        resource_method :w, [:shell_exec]

        #
        # Shows when users last logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `lastlog` command.
        #
        # @see #exec
        #
        def lastlog(*arguments,&block)
          exec('lastlog',*arguments,&block)
        end
        resource_method :lastlog, [:shell_exec]

        #
        # Shows login failures.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `faillog` command.
        #
        # @see #exec
        #
        def faillog(*arguments,&block)
          exec('faillog',*arguments,&block)
        end
        resource_method :faillog, [:shell_exec]

        #
        # Shows the current running processes.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ps` command.
        #
        # @see #exec
        #
        def ps(*arguments,&block)
          exec('ps',*arguments,&block)
        end
        resource_method :ps, [:shell_exec]

        #
        # Runs `ps aux`.
        #
        # @see #ps
        #
        def ps_aux(*arguments,&block)
          ps('aux',*arguments,&block)
        end
        resource_method :ps_aux, [:shell_exec]

        #
        # Kills a current running process.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `kill` command.
        #
        # @return [String]
        #   Output from the `kill` command.
        #
        def kill(*arguments)
          command('kill',*arguments).first
        end
        resource_method :kill, [:shell_exec]

        #
        # Shows information about network interfaces.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ifconfig` command.
        #
        # @see #exec
        #
        def ifconfig(*arguments,&block)
          exec('ifconfig',*arguments,&block)
        end
        resource_method :ifconfig, [:shell_exec]

        #
        # Shows network connections.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `netstat` command.
        #
        # @see #exec
        #
        def netstat(*arguments,&block)
          exec('netstat',*arguments,&block)
        end
        resource_method :netstat, [:shell_exec]

        #
        # Runs `netstat -anp`.
        #
        # @see #netstat
        #
        def netstat_anp(*arguments,&block)
          netstat('-anp',*arguments,&block)
        end
        resource_method :netstat_anp, [:shell_exec]

        #
        # Pings an IP address.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ping` command.
        #
        # @see #exec
        #
        def ping(*arguments,&block)
          exec('ping',*arguments,&block)
        end
        resource_method :ping, [:shell_exec]

        #
        # Runs net-cat.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `nc` command.
        #
        # @see #exec
        #
        def nc(*arguments,&block)
          exec('nc',*arguments,&block)
        end
        resource_method :nc, [:shell_exec]

        #
        # Runs `nc -l`.
        #
        # @see #nc
        #
        def nc_listen(port,*arguments,&block)
          nc('-l',port,*arguments,&block)
        end
        resource_method :nc_listen, [:shell_exec]

        #
        # Connects to a host using net-cat.
        #
        # @param [String] host
        #   The host to connect to.
        #
        # @param [Integer] port
        #   The port to connect to.
        #
        # @see #nc
        #
        def nc_connect(host,port,*arguments,&block)
          nc(host,port,*arguments,&block)
        end
        resource_method :nc_connect, [:shell_exec]

        #
        # Compiles some C source-code with `gcc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `gcc` command.
        #
        # @see #exec
        #
        def gcc(*arguments,&block)
          exec('gcc',*arguments,&block)
        end
        resource_method :gcc, [:shell_exec]

        #
        # Compiles some C source-code with `cc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cc` command.
        #
        # @see #exec
        #
        def cc(*arguments,&block)
          exec('cc',*arguments,&block)
        end
        resource_method :cc, [:shell_exec]

        #
        # Runs a PERL script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `perl` command.
        #
        # @see #exec
        #
        def perl(*arguments,&block)
          exec('perl',*arguments,&block)
        end
        resource_method :perl, [:shell_exec]

        #
        # Runs a Python script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `python` command.
        #
        # @see #exec
        #
        def python(*arguments,&block)
          exec('python',*arguments,&block)
        end
        resource_method :python, [:shell_exec]

        #
        # Runs a Ruby script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ruby` command.
        #
        # @see #exec
        #
        def ruby(*arguments,&block)
          exec('ruby',*arguments,&block)
        end
        resource_method :ruby, [:shell_exec]

        #
        # Exits the shell.
        #
        def exit
          exec('exit')
        end
        resource_method :exit, [:shell_exec]

        #
        # Starts an interactive Shell console.
        #
        def interact
          CLI::ShellShell.start(self)
        end

      end
    end
  end
end
