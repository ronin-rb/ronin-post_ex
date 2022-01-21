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

require 'ronin/core/cli/command_shell'

module Ronin
  module PostEx
    module CLI
      #
      # A shell for {Resources::FS}.
      #
      class SystemCommandShell < Core::CLI::CommandShell

        shell_name 'ronin-post_ex'

        #
        # Initializes the file-system shell.
        #
        # @param [System] system
        #   The file-system resource.
        #
        def initialize(system)
          @system = system
        end

        private

        command 'fs.cd', usage: 'DIR',
                             summary: 'Changes the current working directory'

        #
        # Changes the working directory.
        #
        # @param [String] path
        #   The new working directory.
        #
        # @see Resources::FS#chdir
        #
        def cd(path)
          @system.fs.chdir(path)
          puts "Current working directory is now: #{@system.fs.pwd}"
        end

        command 'fs.pwd', summary: 'Prints the current working directory'

        #
        # Prints the current working directory.
        #
        # @see Resources::FS#getcwd
        #
        def pwd
          puts "Current working directory: #{@system.fs.getcwd}"
        end

        command 'fs.cat', usage: 'FILE',
                          summary: 'Reads the contents of a given FILE'

        #
        # Reads data from a file.
        #
        # @param [String] path
        #   The file to read from.
        #
        # @see Resources::FS#read
        #
        def cat(path)
          write(@system.fs.read(path))
        end

        command 'fs.readlink', usage: 'SYMLINK',
                               summary: 'Reads the destination path of a symlink'

        #
        # Reads the destination of a link.
        #
        # @param [String] path
        #   The path to the link.
        #
        # @see Resources::FS#readlink
        #
        def readlink(path)
          puts @system.fs.readlink(path)
        end

        command 'fs.dir', usage: 'DIR',
                          summary: 'Reads the contents of a given directory'

        #
        # Reads the entries of a directory.
        #
        # @param [String] path
        #   The path to the directory.
        #
        # @see Resources::FS#readdir
        #
        def dir(path)
          @system.fs.readdir(path).each do |entry|
            puts entry
          end
        end

        command 'hexdump', usage: 'FILE',
                           summary: 'Hexdumps a given file'

        #
        # Hexdumps a file.
        #
        # @param [String] path
        #   The file to hexdump.
        #
        # @see Resources::FS#hexdump
        #
        def hexdump(path)
          @system.fs.hexdump(path,self)
        end

        command 'fs.cp', usage: 'SRC DEST',
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
        # @see Resources::FS#copy
        #
        def cp(src,dest)
          @system.fs.copy(src,dest)

          puts "Copied #{@system.fs.join(src)} -> #{@fs.join(dest)}"
        end

        command 'fs.rm', usage: 'FILE',
                         summary: 'Removes a given file'

        #
        # Removes a file.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see Resources::FS#unlink
        #
        def rm(path)
          @system.fs.unlink(path)

          puts "Removed #{@system.fs.join(path)}"
        end

        command 'fs.rmdir', usage: 'DIR',
                            summary: 'Removes a given directory'

        #
        # Removes an empty directory.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see Resources::FS#rmdir
        #
        def rmdir(path)
          @system.fs.rmdir(path)

          puts "Removed directory #{@system.fs.join(path)}"
        end

        command 'fs.mv', usage: 'SRC DEST',
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
        # @see Resources::FS#move
        #
        def mv(src,dest)
          @system.fs.move(src,dest)

          puts "Moved #{@system.fs.join(src)} -> #{@fs.join(dest)}"
        end

        command 'fs.ln', usage: 'SRC DEST',
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
        # @see Resources::FS#link
        #
        def ln(src,dest)
          @system.fs.link(src,dest)

          puts "Linked #{@system.fs.join(src)} -> #{@fs.join(dest)}"
        end

        command 'fs.chown', usage: 'USER PATH',
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
        # @see Resources::FS#chown
        #
        def chown(user,path)
          @system.fs.chown(user,path)

          puts "Changed ownership of #{@system.fs.join(path)} to #{user}"
        end

        command 'fs.chgrp', usage: 'GROUP PATH',
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
        # @see Resources::FS#chgrp
        #
        def chgrp(group,path)
          @system.fs.chgrp(group,path)

          puts "Changed group ownership of #{@system.fs.join(path)} to #{group}"
        end

        command 'fs.chmod', usage: 'MODE PATH',
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
        # @see Resources::FS#chmod
        #
        def chmod(mode,path)
          @system.fs.chmod(mode.to_i(8),path)

          puts "Changed permissions on #{@system.fs.join(path)} to #{mode}"
        end

        command 'fs.stat', usage: 'PATH',
                           summary: 'Prints file system information about a given file or directory'

        #
        # Stats a file or directory.
        #
        # @param [String] path
        #   The file or directory to stat.
        #
        # @see Resources::FS#stat
        #
        def stat(path)
          stat = @system.fs.stat(path)
        end

      end
    end
  end
end
