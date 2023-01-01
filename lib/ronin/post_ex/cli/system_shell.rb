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

require 'ronin/core/cli/command_shell'
require 'ronin/post_ex/cli/shell_shell'
require 'ronin/post_ex/remote_file'

module Ronin
  module PostEx
    module CLI
      #
      # A shell for {System}.
      #
      class SystemShell < Core::CLI::CommandShell

        shell_name 'ronin-post_ex'

        #
        # Initializes the file-system shell.
        #
        # @param [System] system
        #   The file-system resource.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        def initialize(system, **kwargs)
          super(**kwargs)

          @system = system

          @files = {}
          @next_file_id = 1
        end

        command 'fs.chdir', method_name: 'fs_chdir',
                            usage: 'DIR',
                            summary: 'Changes the current working directory'

        #
        # Changes the working directory.
        #
        # @param [String] path
        #   The new working directory.
        #
        # @see System::FS#chdir
        #
        def fs_chdir(path)
          @system.fs.chdir(path)
          puts "Current working directory is now: #{@system.fs.pwd}"
        end

        command 'fs.pwd', method_name: 'fs_pwd',
                          summary: 'Prints the current working directory'

        #
        # Prints the current working directory.
        #
        # @see System::FS#getcwd
        #
        def fs_pwd
          puts "Current working directory: #{@system.fs.getcwd}"
        end

        command 'fs.readfile', method_name: 'fs_readfile',
                               usage: 'FILE',
                               summary: 'Reads the contents of a given FILE'

        #
        # Reads data from a file.
        #
        # @param [String] path
        #   The file to read from.
        #
        # @see System::FS#read
        #
        def fs_readfile(path)
          write(@system.fs.readfile(path))
        end

        command 'fs.readlink', method_name: 'fs_readlink',
                               usage: 'SYMLINK',
                               summary: 'Reads the destination path of a symlink'

        #
        # Reads the destination of a link.
        #
        # @param [String] path
        #   The path to the link.
        #
        # @see System::FS#readlink
        #
        def fs_readlink(path)
          puts @system.fs.readlink(path)
        end

        command 'fs.readdir', method_name: 'fs_readdir',
                              usage: 'DIR',
                              summary: 'Reads the contents of a given directory'

        #
        # Reads the entries of a directory.
        #
        # @param [String] path
        #   The path to the directory.
        #
        # @see System::FS#readdir
        #
        def fs_readdir(path)
          @system.fs.readdir(path).each do |entry|
            puts entry
          end
        end

        command 'fs.hexdump', usage: 'FILE',
                              summary: 'Hexdumps a given file'

        #
        # Hexdumps a file.
        #
        # @param [String] path
        #   The file to hexdump.
        #
        # @see System::FS#hexdump
        #
        def hexdump(path)
          @system.fs.hexdump(path,self)
        end

        command 'fs.copy', method_name: 'file_copy',
                           usage: 'SRC DEST',
                           summary: 'Copies the SRC file to the DEST path'

        #
        # Copies a file to a destination.
        #
        # @param [String] src
        #   The file to copy.
        #
        # @param [String] dest
        #   The destination to copy the file to.
        #
        # @see System::FS#copy
        #
        def fs_copy(src,dest)
          @system.fs.copy(src,dest)

          puts "Copied #{@system.fs.expand_path(src)} -> #{@fs.expand_path(dest)}"
        end

        command 'fs.unlink', method_name: 'file_unlink',
                             usage: 'FILE',
                             summary: 'Deletes a given file'

        #
        # Removes a file.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see System::FS#unlink
        #
        def file_unlink(path)
          @system.fs.unlink(path)

          puts "Removed #{@system.fs.expand_path(path)}"
        end

        command 'fs.rmdir', method_name: 'fs_rmdir',
                            usage: 'DIR',
                            summary: 'Removes a given directory'

        #
        # Removes an empty directory.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see System::FS#rmdir
        #
        def fs_rmdir(path)
          @system.fs.rmdir(path)

          puts "Removed directory #{@system.fs.expand_path(path)}"
        end

        command 'fs.mv', method_name: 'fs_mv',
                         usage: 'SRC DEST',
                         summary: 'Moves or renames a given file or directory'

        #
        # Moves a file or directory.
        #
        # @param [String] src
        #   The file or directory to move.
        #
        # @param [String] dest
        #   The destination to move the file or directory to.
        #
        # @see System::FS#move
        #
        def fs_mv(src,dest)
          @system.fs.move(src,dest)

          puts "Moved #{@system.fs.expand_path(src)} -> #{@fs.expand_path(dest)}"
        end

        command 'fs.link', method_name: 'fs_link',
                           usage: 'SRC DEST',
                           summary: 'Creates a link from the source to the destination'

        #
        # Creates a link to a file or directory.
        #
        # @param [String] src
        #   The file or directory to link to.
        #
        # @param [String] dest
        #   The path of the new link.
        #
        # @see System::FS#link
        #
        def fs_link(src,dest)
          @system.fs.link(src,dest)

          puts "Linked #{@system.fs.expand_path(src)} -> #{@fs.expand_path(dest)}"
        end

        command 'fs.chown', method_name: 'fs_chown',
                            usage: 'USER PATH',
                            summary: 'Changes the owner of a given file or directory'

        #
        # Changes ownership of a file or directory.
        #
        # @param [String] user
        #   The desired new user.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @see System::FS#chown
        #
        def fs_chown(user,path)
          @system.fs.chown(user,path)

          puts "Changed ownership of #{@system.fs.expand_path(path)} to #{user}"
        end

        command 'fs.chgrp', method_name: 'fs_chgrp',
                            usage: 'GROUP PATH',
                            summary: 'Changes the group of a given file or directory'

        #
        # Changes group ownership of a file or directory.
        #
        # @param [String] group
        #   The desired new group.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @see System::FS#chgrp
        #
        def fs_chgrp(group,path)
          @system.fs.chgrp(group,path)

          puts "Changed group ownership of #{@system.fs.expand_path(path)} to #{group}"
        end

        command 'fs.chmod', method_name: 'fs_chmod',
                            usage: 'MODE PATH',
                            summary: 'Changes the permission mode of a given file or directory'

        #
        # Changes the permissions of a file or directory.
        #
        # @param [String] mode
        #   The desired new octal permission mode.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @see System::FS#chmod
        #
        def fs_chmod(mode,path)
          @system.fs.chmod(mode.to_i(8),path)

          puts "Changed permissions on #{@system.fs.expand_path(path)} to #{mode}"
        end

        command 'fs.stat', method_name: 'fs_stat',
                           usage: 'PATH',
                           summary: 'Prints file system information about a given file or directory'

        #
        # Stats a file or directory.
        #
        # @param [String] path
        #   The file or directory to stat.
        #
        # @see System::FS#stat
        #
        def fs_stat(path)
          stat = @system.fs.stat(path)
        end

        command 'file.open', method_name: 'file_open',
                             usage: 'PATH [MODE]',
                             summary: 'Opens a file for reading or writing'

        #
        # Opens a file.
        #
        # @param [String] path
        #   The path to the file.
        #
        # @param [String] mode
        #   Optional open mode.
        #
        # @see System::FS#open
        #
        def file_open(path,mode="r")
          file    = @system.fs.open(path,mode)
          file_id = @next_file_id

          @files[file_id] = file
          @next_file_id  += 1

          puts "Opened file ##{file_id} for #{file.path}"
        end

        command 'files', summary: 'Lists opened files'

        #
        # Lists opened files.
        #
        def files
          @files.each_with_index do |file,index|
            if file
              id = index + 1

              puts "  [#{id}] #{file.path}"
            end
          end
        end

        command 'file.seek', method_name: 'file_seek',
                             usage: 'FILE_ID POS [SEEK_SET | SEEK_CUR | SEEK_END | SEEK_DATA | SEEK_HOLE]',
                             summary: 'Seeks to a position within the file'

        # Mapping of String whence values to Integer values.
        WHENCE = {
          'SEEK_SET'  => RemoteFile::SEEK_SET,
          'SEEK_CUR'  => RemoteFile::SEEK_CUR,
          'SEEK_END'  => RemoteFile::SEEK_END,
          'SEEK_DATA' => RemoteFile::SEEK_DATA,
          'SEEK_HOLE' => RemoteFile::SEEK_HOLE
        }

        #
        # Seeks to a position within an opened file.
        #
        # @param [String] file_id
        #   The file ID number.
        #
        # @param [String] pos
        #   The position to seek to.
        #
        # @param [String] whence
        #   Where to seek relative from. Acceptable values are:
        #   * `"SET"`
        #   * `"CUR"`
        #   * `"END"`
        #   * `"DATA"`
        #   * `"HOLE"`
        #
        # @see RemoteFile#seek
        #
        def file_seek(file_id,pos,whence='SEEK_SET')
          unless WHENCE.has_key?(whence)
            print_error "unknown file.seek whence value (#{whence}), must be #{WHENCE.keys.join(', ')}"
            return false
          end

          file_id = file_id.to_i
          pos     = pos.to_i
          whence  = WHENCE[whence]

          if (file = @files[file_id])
            file.seek(pos,whence)
            puts file.pos
          else
            print_error "unknown file id: #{file_id}"
          end
        end

        command 'file.read', method_name: 'file_read',
                             usage: 'FILE_ID LENGTH',
                             summary: 'Reads LENGTH of data from an opened file'

        #
        # Reads data from an opened file.
        #
        # @param [String] file_id
        #   The file ID number.
        #
        # @param [String] length
        #   The length of data to read.
        #
        # @see RemoteFile#read
        #
        def file_read(file_id,length)
          file_id = file_id.to_i
          length  = length.to_i

          if (file = @files[file_id])
            puts(file.read(length))
          else
            print_error "unknown file id: #{file_id}"
          end
        end

        command 'file.write', method_name: 'file_write',
                              usage: 'FILE_ID DATA',
                              summary: 'Writes data to an opened file'

        #
        # Writes data from to an opened file.
        #
        # @param [String] file_id
        #   The file ID number.
        #
        # @param [String] data
        #   The data to write.
        #
        # @see RemoteFile#write
        #
        def file_write(file_id,data)
          file_id = file_id.to_i
          length  = length.to_i

          if (file = @files[file_id])
            puts file.write(length)
          else
            print_error "unknown file id: #{file_id}"
          end
        end

        command 'file.close', method_name: 'file_close',
                              usage: 'FILE_ID',
                              summary: 'Closes an open file'

        #
        # Closes an opened file.
        #
        # @param [String] file_id
        #   The file ID number.
        #
        # @see RemoteFile#close
        #
        def file_close(file_id)
          file_id = file_id.to_i
          length  = length.to_i

          if (file = @files[file_id])
            file.close
            @files.delete(file_id)

            puts "Closed file ##{file_id} for #{file.path}"
          else
            print_error "unknown file id: #{file_id}"
          end
        end

        command 'process.pid', method_name: 'process_pid',
                               summary: "Prints the process'es PID"

        #
        # Prints the process'es PID.
        #
        # @see System::Process#getpid
        #
        def process_pid
          puts @system.process.getpid
        end

        command 'process.ppid', method_name: 'process_ppid',
                               summary: "Prints the process'es PPID"

        #
        # Prints the process'es PPID.
        #
        # @see System::Process#getppid
        #
        def process_ppid
          puts @system.process.getppid
        end

        command 'process.uid', method_name: 'process_uid',
                               summary: "Prints the process'es UID"

        #
        # Prints the process'es UID.
        #
        # @see System::Process#getuid
        #
        def process_uid
          puts @system.process.getuid
        end

        command 'process.setuid', method_name: 'process_setuid',
                                  usage: 'UID',
                                  summary: "Sets the process'es UID"

        #
        # Sets the process'es UID.
        #
        # @param [String] new_uid
        #
        # @see System::Process#setuid
        #
        def process_setuid(new_uid)
          @system.process.setuid(new_uid.to_i)
        end

        command 'process.euid', method_name: 'process_euid',
                                usage: 'EUID',
                                summary: "Prints the process'es EUID"

        #
        # Prints the process'es EUID.
        #
        # @see System::Process#geteuid
        #
        def process_euid
          puts @system.process.geteuid
        end

        command 'process.seteuid', method_name: 'process_seteuid',
                                  usage: 'EUID',
                                  summary: "Sets the process'es EUID"

        #
        # Sets the process'es EUID.
        #
        # @param [String] new_euid
        #
        # @see System::Process#seteuid
        #
        def process_seteuid(new_euid)
          @system.process.seteuid(new_euid.to_i)
        end

        command 'process.gid', method_name: 'process_gid',
                               usage: 'COMMAND',
                               summary: "Prints the process'es GID"

        #
        # Prints the process'es GID.
        #
        # @see System::Process#getgid
        #
        def process_gid
          puts @system.process.getgid
        end

        command 'process.setgid', method_name: 'process_setgid',
                                  usage: 'GID',
                                  summary: "Sets the process'es GID"

        #
        # Sets the process'es GID.
        #
        # @param [String] new_gid
        #
        # @see System::Process#setgid
        #
        def process_setgid(new_gid)
          @system.process.setgid(new_gid.to_i)
        end

        command 'process.egid', method_name: 'process_egid',
                                summary: "Prints the process'es EGID"

        #
        # Prints the process'es EGID.
        #
        # @see System::Process#getegid
        #
        def process_egid
          puts @system.process.getegid
        end

        command 'process.setegid', method_name: 'process_setegid',
                                   usage: 'EGID',
                                   summary: "Sets the process'es EGID"

        #
        # Sets the process'es EGID.
        #
        # @param [String] new_egid
        #
        # @see System::Process#setegid
        #
        def process_setegid(new_egid)
          @system.process.setegid(new_egid.to_i)
        end

        command 'process.sid', method_name: 'process_sid',
                               summary: "Prints the process'es SID"

        #
        # Prints the process'es SID.
        #
        # @see System::Process#getsid
        #
        def process_sid
          puts @system.process.getsid
        end

        command 'process.setsid', method_name: 'process_setsid',
                                  usage: 'SID',
                                  summary: "Prints the process'es SID"

        #
        # Sets the process'es SID.
        #
        # @param [String] new_sid
        #
        # @see System::Process#setsid
        #
        def process_setsid(new_sid)
          @system.process.setsid(new_sid.to_i)
        end

        command 'process.env', method_name: 'process_env',
                               summary: "Prints the process'es environment variables"

        #
        # Prints the process'es environment variables.
        #
        # @see System::Process#environ
        #
        def process_env
          @system.process.env.each do |name,value|
            puts "#{name}=#{value}"
          end
        end

        command 'process.getenv', method_name: 'process_getenv',
                                  usage: 'NAME',
                                  summary: 'Prints an environment variable from the process'

        #
        # Prints a specific environment variable from the process.
        #
        # @param [String] name
        #   The environment variable name.
        #
        # @see System::Process#getenv
        #
        def process_getenv(name)
          puts @system.process.getenv(name)
        end

        command 'process.setenv', method_name: 'process_setenv',
                                  usage: 'NAME=VALUE',
                                  summary: 'Sets an environment variable for the process'

        #
        # Sets a specific environment variable from the process.
        #
        # @param [String] name_and_value
        #   The environment variable name.
        #
        # @see System::Process#getenv
        #
        def process_setenv(name_and_value)
          name, value = name_and_value.split('=',2)

          @system.process.setenv(name,value)
        end

        command 'process.unsetenv', method_name: 'process_getenv',
                                    usage: 'NAME',
                                    summary: 'Unsets an environment variable for the process'

        #
        # Unsets a process environment variable.
        #
        # @param [String] name
        #   The environment variable to unset.
        #
        # @see System::Process#unsetenv
        #
        def process_unsetenv(name)
          @system.process.unsetenv(name)
        end

        command 'process.kill', method_name: 'process_kill',
                                usage: 'PID [SIGNAL]',
                                summary: 'Kills a process'

        #
        # Kills a process.
        #
        # @param [String] pid
        #   The process PID to kill.
        #
        # @param [String] signal
        #   The signal to send the process.
        #
        def process_kill(pid,signal='KILL')
          @system.process.kill(pid.to_i,signal)
        end

        command 'process.spawn', method_name: 'process_spawn',
                                 usage: 'PROGRAM [ARGS ...]',
                                 summary: 'Spawns a new process'

        #
        # Spawns a new process.
        #
        # @param [String] program
        #   The program name.
        #
        # @param [Array<String>] arguments
        #   Additional command arguments.
        #
        # @see System::Process#spawn
        #
        def process_spawn(program,*arguments)
          pid = @system.process.spawn(program,*arguments)

          puts "PID: #{pid}"
        end

        command 'shell.exec', method_name: 'shell_exec',
                              usage: 'COMMAND',
                              summary: 'Executes a command in the shell'

        #
        # Executes a shell command.
        #
        # @param [String] command
        #   The command to execute.
        #
        # @see System::Shell#run
        #
        def shell_exec(command)
          puts @system.shell.run(command)
        end

        command 'shell', method_name: 'shell',
                         summary: 'Spawns an interactive command shell'

        #
        # Spawns an interactive command sub-shell.
        #
        # @see ShellShell
        #
        def shell
          ShellShell.start(@system.shell)
        end

        command 'sys.time', method_name: 'sys_time',
                            summary: "Prints the system's current time"

        #
        # Prints the system's current time.
        #
        # @see System#time
        #
        def sys_time
          puts @system.time
        end

        command 'sys.hostname', method_name: 'sys_hostname',
                            summary: "Prints the system's hostname"

        #
        # Prints the system's hostname.
        #
        # @see System#hostname
        #
        def sys_hostname
          puts @system.hostname
        end

      end
    end
  end
end
