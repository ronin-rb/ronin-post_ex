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

require 'ronin/core/cli/command_shell'

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
          @files  = []
        end

        private

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

        command 'fs.open', method_name: 'fs_open',
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
        def fs_open(path,mode="r")
          file = @system.fs.open(path,mode)
          @files << file

          puts "Opened file #{file.path}"
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
                             usage: 'FILE_ID POS [WHENCE]',
                             summary: 'Seeks to a position within the file'

        WHENCE = {
          'SET'  => File::SEEK_SET,
          'CUR'  => File::SEEK_CUR,
          'END'  => File::SEEK_END,
          'DATA' => File::SEEK_DATA,
          'HOLE' => File::SEEK_HOLE
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
        def file_seek(file_id,pos,whence='SET')
          unless WHENCE.has_key?(whence)
            print_error "unknown file.seek whence value (#{whence})"
          end

          file_id = file_id.to_i
          pos     = pos.to_i
          whence  = WHENCE[whence]

          if (file = @files[file_id])
            file.seek(pos,whence)
            puts file.pos
          else
            print_error "unknown file id"
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
            write(file.read(length))
          else
            print_error "unknown file id"
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
            print_error "unknown file id"
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
            @files[file_id] = nil
            puts "Closed file ##{file_id}"
          else
            print_error "unknown file id"
          end
        end

        command 'shell.exec', method_name: 'shell_exec',
                              usage: 'COMMAND',
                              summary: 'Executes the command in a shell'

        #
        # Executes a shell command.
        #
        # @param [String] command
        #   The command to execute.
        #
        # @see System::Shell#run
        #
        def shell_exec(command)
          print @system.shell.run(command)
        end

      end
    end
  end
end
