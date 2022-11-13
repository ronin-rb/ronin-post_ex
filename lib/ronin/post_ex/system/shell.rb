#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
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
      # * `shell_exec(command : String) -> String`
      #
      class Shell < Resource

        # Persistent environment variables for the shell.
        #
        # @return {Hash{String => String}]
        attr_reader :env

        #
        # Initializes the Shell resource.
        #
        # @param [#shell_exec] api
        #   The API object that defines the `shell_exec` method.
        #
        def initialize(api)
          super(api)

          @cwd = nil
          @env = {}
        end

        #
        # Executes a shell command and returns it's output.
        #
        # @param [String] command
        #   The shell command to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the shell command.
        #
        # @example
        #   run 'ls'
        #
        # @example with additional arguments:
        #   run 'ls', '-l'
        #
        # @return [String]
        #   The output of the shell command.
        #
        def run(command,*arguments)
          unless arguments.empty?
            command = "#{command} #{Shellwords.shelljoin(arguments)}"
          end

          unless @env.empty?
            env_vars = @env.map { |key,value|
              "#{key}=#{Shellwords.shellescape(value)}"
            }.join(' ')

            command = "env #{env_vars} #{command}"
          end

          if @cwd
            command = "cd #{@cwd} && #{command}"
          end

          return @api.shell_exec(command)
        end
        resource_method :run, [:shell_exec]

        #
        # Executes a command and prints the resulting output.
        #
        # @param [String] command
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the shell command.
        #
        # @return [nil]
        #
        def system(command,*arguments)
          puts(run(command,*arguments))
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
          @pwd = File.expand_path(path,pwd)
        end
        resource_method :cd, [:shell_exec]

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        def pwd
          @pwd ||= run('pwd').chomp
        end
        resource_method :pwd, [:shell_exec]

        #
        # Lists the files or directories.
        #
        # @param [Array<String>] arguments
        #   Arguments to pass to the `ls` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ls(*arguments)
          run('ls',*arguments)
        end
        resource_method :ls, [:shell_exec]

        #
        # Lists all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -a` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ls_a(*arguments)
          run('ls','-a',*arguments)
        end
        resource_method :ls_a, [:shell_exec]

        #
        # Lists information about files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -l` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ls_l(*arguments)
          run('ls','-l',*arguments)
        end
        resource_method :ls_l, [:shell_exec]

        #
        # Lists information about all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -la` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ls_la(*arguments)
          run('ls','-la',*arguments)
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
        def find(*arguments,&block)
          if block
            run('find',*arguments).each_line(chomp: true,&block)
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
          run('file',*arguments)
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
          run('which',*arguments)
        end
        resource_method :which, [:shell_exec]

        #
        # Reads the contents of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cat` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def cat(*arguments)
          run('cat',*arguments)
        end
        resource_method :cat, [:shell_exec]

        #
        # Reads the first `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `head` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def head(*arguments)
          run('head',*arguments)
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
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def head_n(lines,*arguments)
          head('-n',lines,*arguments)
        end
        resource_method :head_n, [:shell_exec]

        #
        # Reads the last `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `tail` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def tail(*arguments)
          run('tail',*arguments)
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
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def tail_n(lines,*arguments)
          tail('-n',lines,*arguments)
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
        def grep(*arguments)
          if block_given?
            run('grep',*arguments).each_line(chomp: true) do |line|
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
        # @param [Array<String>] arguments
        #   Additional arguments for the `grep` command.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all matching paths and lines will be
        #   returned.
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
        # @param [Array<String>] arguments
        #   Additional arguments for the `grep` command.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all matching paths and lines will be
        #   returned.
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
          run('touch',*arguments)
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
          run('mktemp',*arguments).chomp
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
          run('mkdir',*arguments)
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
          run('cp',*arguments)
        end
        resource_method :cp, [:shell_exec]

        #
        # Runs `cp -r`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `cp` command.
        #
        # @return [String]
        #   Any error messages returned by the `cp` command.
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
        # @param [Array<String>] arguments
        #   Additional arguments for the `cp` command.
        #
        # @return [String]
        #   Any error messages returned by the `cp` command.
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
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def rsync(*arguments)
          run('rsync',*arguments)
        end
        resource_method :rsync, [:shell_exec]

        #
        # Runs `rsync -a`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `rsync` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #rsync
        #
        def rsync_a(*arguments)
          rsync('-a',*arguments)
        end
        resource_method :rsync_a, [:shell_exec]

        #
        # Runs `wget`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rsync` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def wget(*arguments)
          run('wget','-q',*arguments)
        end
        resource_method :wget, [:shell_exec]

        #
        # Runs `wget -O`.
        #
        # @param [String] path
        #   The path that `wget` will write to.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `wget` command.
        #
        # @return [String]
        #   The full output of the command.
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
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def curl(*arguments)
          run('curl','-s',*arguments)
        end
        resource_method :curl, [:shell_exec]

        #
        # Runs `curl -O`.
        #
        # @param [String] path
        #   The path that `curl` will write to.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `curl` command.
        #
        # @return [String]
        #   The full output of the command.
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
          run('rmdir',*arguments)
        end
        resource_method :rmdir, [:shell_exec]

        #
        # Removes one or more files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rm` command.
        #
        # @yield [line]
        #   If a block is given, it will be passed each line of output
        #   from the command.
        #
        # @yieldparam [String] line
        #   A line of output from the command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def rm(*arguments)
          run('rm',*arguments)
        end
        resource_method :rm, [:shell_exec]

        #
        # Runs `rm -r`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `rm` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #rm
        #
        def rm_r(*arguments)
          rm('-r',*arguments)
        end
        resource_method :rm_r, [:shell_exec]

        #
        # Runs `rm -rf`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `rm` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #rm
        #
        def rm_rf(*arguments)
          rm('-rf',*arguments)
        end
        resource_method :rm_rf, [:shell_exec]

        #
        # Gets the current time from the shell.
        #
        # @return [Time]
        #   The current time returned by the shell.
        #
        def time
          Time.parse(run('date').chomp)
        end
        resource_method :time, [:shell_exec]

        #
        # Gets the current time and date from the shell.
        #
        # @return [Date]
        #   The current data returned by the shell.
        #
        def date
          time.to_date
        end
        resource_method :date, [:shell_exec]

        #
        # The ID information of the current user.
        #
        # @return [Hash{Symbol => String}]
        #   The ID information returned by the `id` command.
        #
        def id
          hash = {}

          run('id').split.each do |name_value|
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
          run('id','-u').to_i
        end
        resource_method :uid, [:shell_exec]

        #
        # The GID of the current user.
        #
        # @return [Integer]
        #   The GID of the current user.
        #
        def gid
          run('id','-g').to_i
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
          run('whoami',*arguments).chomp
        end
        resource_method :whoami, [:shell_exec]

        #
        # Shows who is currently logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `who` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def who(*arguments)
          run('who',*arguments)
        end
        resource_method :who, [:shell_exec]

        #
        # Similar to {#who} but runs the `w` command.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `w` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def w(*arguments)
          run('w',*arguments)
        end
        resource_method :w, [:shell_exec]

        #
        # Shows when users last logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `lastlog` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def lastlog(*arguments)
          run('lastlog',*arguments)
        end
        resource_method :lastlog, [:shell_exec]

        #
        # Shows login failures.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `faillog` command.
        #
        # @yield [line]
        #   If a block is given, it will be passed each line of output
        #   from the command.
        #
        # @yieldparam [String] line
        #   A line of output from the command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def faillog(*arguments)
          run('faillog',*arguments)
        end
        resource_method :faillog, [:shell_exec]

        #
        # Shows the current running processes.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ps` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ps(*arguments)
          run('ps',*arguments)
        end
        resource_method :ps, [:shell_exec]

        #
        # Runs `ps aux`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `ps` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #ps
        #
        def ps_aux(*arguments)
          ps('aux',*arguments)
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
          run('kill',*arguments)
        end
        resource_method :kill, [:shell_exec]

        #
        # Shows information about network interfaces.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ifconfig` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ifconfig(*arguments)
          run('ifconfig',*arguments)
        end
        resource_method :ifconfig, [:shell_exec]

        #
        # Shows network connections.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `netstat` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def netstat(*arguments)
          run('netstat',*arguments)
        end
        resource_method :netstat, [:shell_exec]

        #
        # Runs `netstat -anp`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the `netstat` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #netstat
        #
        def netstat_anp(*arguments)
          netstat('-anp',*arguments)
        end
        resource_method :netstat_anp, [:shell_exec]

        #
        # Pings an IP address.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ping` command.
        #
        # @yield [line]
        #   If a block is given, it will be passed each line of output
        #   from the command.
        #
        # @yieldparam [String] line
        #   A line of output from the command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ping(*arguments)
          run('ping',*arguments)
        end
        resource_method :ping, [:shell_exec]

        #
        # Compiles some C source-code with `gcc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `gcc` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def gcc(*arguments)
          run('gcc',*arguments)
        end
        resource_method :gcc, [:shell_exec]

        #
        # Compiles some C source-code with `cc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cc` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def cc(*arguments)
          run('cc',*arguments)
        end
        resource_method :cc, [:shell_exec]

        #
        # Runs a PERL script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `perl` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def perl(*arguments)
          run('perl',*arguments)
        end
        resource_method :perl, [:shell_exec]

        #
        # Runs a Python script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `python` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def python(*arguments)
          run('python',*arguments)
        end
        resource_method :python, [:shell_exec]

        #
        # Runs a Ruby script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ruby` command.
        #
        # @return [String]
        #   The full output of the command.
        #
        # @see #exec
        #
        def ruby(*arguments)
          run('ruby',*arguments)
        end
        resource_method :ruby, [:shell_exec]

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
