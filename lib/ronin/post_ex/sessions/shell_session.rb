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

require 'ronin/post_ex/sessions/session'

require 'shellwords'
require 'base64'

module Ronin
  module PostEx
    module Sessions
      #
      # Base class for all interactive shell based post-exploitation sessions.
      #
      # ## Features
      #
      # * Supports Bash, Zsh, and all POSIX shells.
      # * Emulates most of the post-exploitation API via shell commands.
      #
      class ShellSession < Session

        # The IO object used to communicate with the shell.
        #
        # @return [Socket, IO]
        #
        # @api private
        attr_reader :io

        #
        # Initializes the shell session.
        #
        # @param [Socet, IO] io
        #   The IO object used to communicate with the shell.
        #
        def initialize(io)
          @io = io
        end

        #
        # @group Shell Methods
        #

        #
        # Writes a line to the shell.
        #
        # @param [String] line
        #   The line to write.
        #
        # @api private
        #
        def shell_puts(line)
          @io.write("#{line}\n")
        end

        #
        # Reads a line from the shell.
        #
        # @return [String, nil]
        #
        # @api private
        #
        def shell_gets
          @io.gets
        end

        # Deliminator line to indicate the beginning and end of output
        DELIMINATOR = '---'

        #
        # Executes a shell command and returns it's output.
        #
        # @param [String] command
        #   The shell command to execute.
        #
        # @return [String]
        #   The output of the shell command.
        #
        def shell_exec(command)
          shell_puts("echo #{DELIMINATOR}; #{command} 2>/dev/null | base64; echo #{DELIMINATOR}")

          # consume any leading output before the command output
          while (line = shell_gets)
            if line.chomp == DELIMINATOR
              break
            end
          end

          output = String.new

          while (line = shell_gets)
            if line.chomp == DELIMINATOR
              break
            end

            output << line
          end

          return Base64.decode64(output)
        end

        #
        # Joins a command with arguments into a single command String.
        #
        # @param [String] command
        #   The command name to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the command.
        #
        # @return [String]
        #   The command string.
        #
        # @api private
        #
        def command_join(command,*arguments)
          Shellwords.join([command,*arguments])
        end

        #
        # Invokes a specific command with arguments.
        #
        # @param [String] command
        #   The command name to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the command.
        #
        # @return [String, nil]
        #   The command's output or `nil` if there was no output.
        #
        # @api private
        #
        def command_exec(command,*arguments)
          output = shell_exec(command_join(command,*arguments))

          if output.empty? then nil
          else                  output
          end
        end

        #
        # @group System Methods
        #

        #
        # Gets the current time and returns the UNIX timestamp.
        #
        # @return [Integer]
        #   The current time as a UNIX timestamp.
        #
        # @note executes the `date +%s` command.
        #
        def sys_time
          shell_exec('date +%s').to_i
        end

        #
        # Gets the system's hostname.
        #
        # @return [String]
        #
        # @note executes the `echo $HOSTNAME` command.
        #
        def sys_hostname
          shell_exec("echo $HOSTNAME").chomp
        end

        #
        # @group File-System methods
        #

        #
        # Gets the current working directory and returns the directory path.
        #
        # @return [String]
        #   The remote current working directory.
        #
        # @note executes the `pwd` command.
        #
        def fs_getcwd
          shell_exec('pwd').chomp
        end

        #
        # Changes the current working directory.
        #
        # @param [String] path
        #   The new remote current working directory.
        #
        # @note executes the `cd <path>` command.
        #
        def fs_chdir(path)
          shell_puts("cd #{Shellwords.escape(path)} 2>/dev/null")
        end

        #
        # Reads the entire file at the given path and returns the full file's
        # contents.
        #
        # @param [String] path
        #   The remote path to read.
        #
        # @return [String, nil]
        #   The contents of the remote file or `nil` if the file could not be
        #   read.
        #
        # @note executes the `cat <path>` command.
        #
        def fs_readfile(path)
          command_exec('cat',path)
        end

        #
        # Reads the destination path of a remote symbolic link.
        #
        # @param [String] path
        #   The remote path to read.
        #
        # @return [String, nil]
        #   The destination of the remote symbolic link or `nil` if the symbolic
        #   link could not be read.
        #
        # @note executes the `readlink -f <path>` command.
        #
        def fs_readlink(path)
          command_exec('readlink','-f',path).chomp
        end

        #
        # Reads the contents of a remote directory and returns an Array of
        # directory entry names.
        #
        # @param [String] path
        #   The path of the remote directory to read.
        #
        # @return [Array<String>]
        #   The entities within the remote directory.
        #
        # @note executes the `ls <path>` command.
        #
        def fs_readdir(path)
          command_exec('ls',path).lines(chomp: true)
        end

        #
        # Evaluates a directory glob pattern and returns all matching paths.
        #
        # @param [String] pattern
        #   The glob pattern to search for remotely.
        #
        # @return [Array<String>]
        #   The matching paths.
        #
        # @note executes the `ls <pattern>` command.
        #
        def fs_glob(pattern,&block)
          shell_exec("ls #{pattern}").lines(chomp: true)
        end

        #
        # Creates a remote temporary file with the given file basename.
        #
        # @param [String] basename
        #   The basename for the new temporary file.
        #
        # @return [String]
        #   The path of the newly created temporary file.
        #
        # @note executes the `mktemp <basename>` command.
        #
        def fs_mktemp(basename)
          command_exec('mktemp',basename).chomp
        end

        #
        # Creates a new remote directory at the given path.
        #
        # @param [String] new_path
        #   The new remote directory to create.
        #
        # @note executes the `mkdir <path>` command.
        #
        def fs_mkdir(new_path)
          command_exec('mkdir',new_path)
        end

        #
        # Copies a source file to the destination path.
        #
        # @param [String] path
        #   The source file.
        #
        # @param [String] new_path
        #   The destination path.
        #
        # @note executes the `cp -r <path> <new_path>` command.
        #
        def fs_copy(path,new_path)
          command_exec('cp','-r',path,new_path)
        end

        #
        # Removes a file at the given path.
        #
        # @param [String] path
        #   The remote path to remove.
        #
        # @note executes the `rm <path>` command.
        #
        def fs_unlink(path)
          command_exec('rm',path)
        end

        #
        # Removes an empty directory at the given path.
        #
        # @param [String] path
        #   The remote directory path to remove.
        #
        # @note executes the `rmdir <path>` command.
        #
        def fs_rmdir(path)
          command_exec('rmdir',path)
        end

        #
        # Moves or renames a remote source file to a new destination path.
        #
        # @param [String] path
        #   The source file path.
        #
        # @param [String] new_path
        #   The destination file path.
        #
        # @note executes the `mv <path> <new_path>` command.
        #
        def fs_move(path,new_path)
          command_exec('mv',path,new_path)
        end

        #
        # Creates a remote symbolic link at the destination path pointing to the
        # source path.
        #
        # @param [String] src
        #   The source file path for the new symbolic link.
        #
        # @param [String] dest
        #   The remote path of the new symbolic link.
        #
        # @note executes the `ln -s <src> <dest>` command.
        #
        def fs_link(src,dest)
          command_exec('ln','-s',src,dest)
        end

        #
        # Changes the group ownership of a remote file or directory.
        #
        # @param [String] group
        #   The new group name for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note executes the `chgrp <group> <path>` command.
        #
        def fs_chgrp(group,path)
          command_exec('chgrp',group,path)
        end

        #
        # Changes the user ownership of remote a file or directory.
        #
        # @param [String] user
        #   The new user for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note executes the `chown <user> <path>` command.
        #
        def fs_chown(user,path)
          command_exec('chown',user,path)
        end

        #
        # Changes the permissions on a remote file or directory.
        #
        # @param [Integer] mode
        #   The permissions mode for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note executes the `chmod <umask> <path>` command.
        #
        def fs_chmod(mode,path)
          umask = "%.4o" % mode

          command_exec('chmod',umask,path)
        end

        #
        # Queries file information for the given remote path and returns a Hash
        # of file metadata.
        #
        # @param [String] path
        #   The path to the remote file or directory.
        #
        # @return [Hash{Symbol => Object}, nil]
        #   The metadata for the remote file.
        #
        # @note executes the `stat -t <path>` command.
        #
        def fs_stat(path)
          fields = command_exec('stat','-t',path).strip.split(' ')

          return {
            path:      path,
            size:      fields[1].to_i,
            blocks:    fields[2].to_i,
            uid:       fields[4].to_i,
            gid:       fields[5].to_i,
            inode:     fields[7].to_i,
            links:     fields[8].to_i,
            atime:     Time.at(fields[11].to_i),
            mtime:     Time.at(fields[12].to_i),
            ctime:     Time.at(fields[13].to_i),
            blocksize: fields[14].to_i
          }
        end

        #
        # @group Process methods
        #

        #
        # Gets the current process's Process ID (PID).
        #
        # @return [Integer]
        #   The current process's PID.
        #
        # @note executes the `echo $$` command.
        #
        def process_getpid
          shell_exec('echo $$').to_i
        end

        #
        # Gets the current process's parent Process ID (PPID).
        #
        # @return [Integer]
        #   The current process's PPID.
        #
        # @note executes the `echo $PPID` command.
        #
        def process_getppid
          shell_exec('echo $PPID').to_i
        end

        #
        # Gets the current process's user ID (UID).
        #
        # @return [Integer]
        #   The current process's UID.
        #
        # @note executes the `id -u` command.
        #
        def process_getuid
          command_exec('id','-u').to_i
        end

        #
        # Gets the current process's group ID (GID).
        #
        # @return [Integer]
        #   The group ID (GID) for the current process.
        #
        # @note executes the `id -g` command.
        #
        def process_getgid
          command_exec('id','-g').to_i
        end

        #
        # Queries all environment variables of the current process. Returns a
        # Hash of the env variable names and values.
        #
        # @return [Hash{String => String}]
        #   The Hash of environment variables.
        #
        # @note executes the `env` command.
        #
        def process_environ
          Hash[command_exec('env').each_line(chomp: true).map { |line|
            line.split('=',2)
          }]
        end

        #
        # Gets an individual environment variable. If the environment variable
        # has not been set, `nil` will be returned.
        #
        # @param [String] name
        #   The environment variable name to get.
        #
        # @return [String]
        #   The environment variable value.
        #
        # @note executes the `echo $<name>` command.
        #
        def process_getenv(name)
          shell_exec("echo $#{name}").chomp
        end

        #
        # Sets an environment variable to the given value.
        #
        # @param [String] name
        #   The environment variable name to set.
        #
        # @param [String] value
        #   The new value for the environment variable.
        #
        # @note executes the `export <name>=<value>` command.
        #
        def process_setenv(name,value)
          shell_puts("export #{name}=#{value}")
        end

        #
        # Un-sets an environment variable.
        #
        # @param [String] name
        #   The environment variable to unset.
        #
        # @note executes the `unset <name>` command.
        #
        def process_unsetenv(name)
          shell_puts("unset #{name}")
        end

        #
        # Kills another process using the given Process ID (POD) and the signal
        # number.
        #
        # @param [Integer] pid
        #   The process ID (PID) to kill.
        #
        # @param [Integer] signal
        #   The signal to send the process ID (PID).
        #
        # @note executes the `kill -s <signal> <pid>` command.
        #
        def process_kill(pid,signal)
          command_exec('kill','-s',signal,pid)
        end

        #
        # Spawns a new process using the given program and additional arguments.
        #
        # @param [String] command
        #   The command name to spawn.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the program.
        #
        # @return [Integer]
        #   The process ID (PID) of the spawned process.
        #
        # @note
        #   executes the command with additional arguments as a background
        #   process.
        #
        def process_spawn(command,*arguments)
          command = command_join(command,*arguments)

          shell_exec("#{command} 2>&1 >/dev/null &; echo $!").to_i
        end

        #
        # Exits the current process.
        #
        # @note executes the `exit` command.
        #
        def process_exit
          shell_puts('exit')
        end

        #
        # Closes the remote shell.
        #
        def close
          @io.close
        end

      end
    end
  end
end
