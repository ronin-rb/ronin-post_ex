#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/leverage/resources/resource'
require 'ronin/leverage/file'
require 'ronin/leverage/file/stat'
require 'ronin/ui/hexdump/hexdump'
require 'ronin/ui/shell'

require 'digest/md5'

module Ronin
  module Leverage
    module Resources
      #
      # Leverages the resources of a File System.
      #
      class FS < Resource

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        # @note
        #   May call the `fs_getcwd` method, if defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def getcwd
          if @leverage.respond_to?(:fs_getcwd)
            @cwd = @leverage.fs_getcwd
          end

          return @cwd
        end

        alias getwd getcwd
        alias pwd getcwd

        #
        # Changes the current working directory.
        #
        # @param [String] path
        #   The path to use as the new current working directory.
        #
        # @return [String]
        #   The new current working directory.
        #
        # @note
        #   May call the `fs_chdir` method, if defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def chdir(path)
          path = join(path)
          old_cwd = @cwd

          @cwd = if @leverage.respond_to?(:fs_chdir)
                   @leverage.fs_chdir(path)
                 else
                   path
                 end

          if block_given?
            yield @cwd
            @cwd = old_cwd
          end

          return @cwd
        end

        #
        # Joins the path with the current working directory.
        #
        # @param [String]
        #   The path to join.
        #
        # @return [String]
        #   The absolute path.
        #
        # @since 0.4.0
        #
        def join(path)
          if (@cwd && path[0,1] != '/')
            ::File.expand_path(::File.join(@cwd,path))
          else
            path
          end
        end

        #
        # Searches the file-system for matching paths.
        #
        # @param [String] pattern
        #   A path-glob pattern.
        #
        # @yield [path]
        #   The given block, will be passed each matching path.
        #
        # @yieldparam [String] path
        #   A path in the file-system that matches the pattern.
        #
        # @return [Array<String>]
        #   If no block is given, the matching paths will be returned.
        #
        # @example
        #   exploit.fs.glob('*.txt')
        #   # => [...]
        #
        # @example
        #   exploit.fs.glob('**/*.xml') do |path|
        #     # ...
        #   end
        #
        # @note
        #   Requires the `fs_glob` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def glob(pattern,&block)
          requires_method! :fs_glob

          path = join(pattern)

          if block
            @leverage.fs_glob(pattern,&block)
          else
            @leverage.enum_for(:fs_glob,pattern).to_a
          end
        end

        #
        # Opens a file for reading.
        #
        # @param [String] path
        #   The path to file.
        #
        # @yield [file]
        #   If a block is given, it will be passed the newly opened file.
        #   After the block has returned, the file will be closed and
        #   `nil` will be returned.
        #
        # @yieldparam [File] file
        #   The temporarily opened file.
        #
        # @return [File, nil]
        #   The newly opened file.
        #
        # @since 0.4.0
        #
        def open(path,&block)
          File.open(@leverage,join(path),&block)
        end

        #
        # Reads the contents of a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @return [String]
        #   The contents of the file.
        #
        # @since 0.4.0
        #
        def read(path)
          open(path).read
        end

        #
        # Hexdumps the contents of a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @param [IO] output
        #   The output stream to write the hexdump to.
        #
        # @return [nil]
        #
        # @since 0.4.0
        #
        def hexdump(path,output=STDOUT)
          open(path) { |file| UI::Hexdump.dump(file,output) }
        end

        #
        # Writes data to a file.
        #
        # @param [String] path
        #   The path to the file.
        #
        # @param [String] data
        #   The data to write.
        #
        # @return [nil]
        # 
        # @since 0.4.0
        #
        def write(path,data)
          open(path) { |file| file.write(data) }
        end

        #
        # Touches a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @return [nil]
        #
        # @since 0.4.0
        #
        def touch(path)
          open(path) { |file| file << '' }
        end

        #
        # Opens a tempfile.
        #
        # @param [String] basename
        #   The base-name to use in the tempfile.
        #
        # @yield [tempfile]
        #   The given block will be passed the newly opened tempfile.
        #   After the block has returned, the tempfile will be closed
        #   and `nil` will be returned.
        #
        # @yieldparam [File] tempfile
        #   The temporarily opened tempfile.
        #
        # @return [File, nil]
        #   The newly opened tempfile.
        #
        # @note
        #   Requires the `fs_mktemp` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def tmpfile(basename,&block)
          requires_method! :fs_mktemp

          open(@leverage.fs_mktemp(basename),&block)
        end

        #
        # Creates a directory.
        #
        # @param [String] path
        #   The path of the directory.
        #
        # @note
        #   Requires the `fs_mkdir` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def mkdir(path)
          requires_method! :fs_mkdir

          @leverage.fs_mkdir(path)
        end

        #
        # Copies a file.
        #
        # @param [String] path
        #   The path of the file to copy.
        #
        # @param [String] new_path
        #   The destination path to copy to.
        #
        # @note
        #   Requires the `fs_copy` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def copy(path,new_path)
          requires_method! :fs_copy

          @leverage.fs_copy(join(path),join(new_path))
        end

        #
        # Unlinks a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @note
        #   Requires the `fs_unlink` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def unlink(path)
          requires_method! :fs_unlink

          @leverage.fs_unlink(join(path))
        end

        alias rm unlink

        #
        # Removes a directory.
        #
        # @param [String] path
        #   The path of the directory.
        #
        # @note
        #   Requires the `fs_rmdir` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def rmdir(path)
          requires_method! :fs_rmdir

          @leverage.fs_rmdir(join(path))
        end

        #
        # Moves a file or directory.
        #
        # @param [String] path
        #   The path of the file or directory to be moved.
        #
        # @param [String] new_path
        #   The destination path for the file or directory to be moved to.
        #
        # @note
        #   Requires the `fs_move` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def move(path,new_path)
          requires_method! :fs_move

          @leverage.fs_move(join(path),join(new_path))
        end

        alias rename move

        #
        # Creates a symbolic link.
        #
        # @param [String] path
        #   The path that the link will point to.
        #
        # @param [String] new_path
        #   The path of the link.
        #
        # @note
        #   Requires the `fs_link` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def link(path,new_path)
          requires_method! :fs_link

          @leverage.fs_link(path,new_path)
        end

        #
        # Changes ownership on one or more files or directories.
        #
        # @param [Array] arguments
        #   The user, optional group and one or more paths to change
        #   ownership.
        #
        # @example
        #   exploit.fs.chown('www', ['one.html'])
        #
        # @note
        #   Requires the `fs_chown` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def chown(*arguments)
          requires_method! :fs_chown

          paths = arguments.pop.map { |path| join(path) }
          @leverage.fs_chown(*arguments,paths)
        end

        #
        # Changes group ownership on one or more files or directories.
        #
        # @param [Array] arguments
        #   The user, optional group and one or more paths to change
        #   ownership.
        #
        # @example
        #   exploit.fs.chgrp('www', ['one.html'])
        #
        # @note
        #   Requires the `fs_chgrp` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def chgrp(*arguments)
          requires_method! :fs_chgrp

          paths = arguments.pop.map { |path| join(path) }
          @leverage.fs_chgrp(*arguments,paths)
        end

        #
        # Changes permissions on one or more files or directories.
        #
        # @param [Array] arguments
        #   The user, optional group and one or more paths to change
        #   permissions.
        #
        # @example
        #   exploit.fs.chmod('www', ['one.html'])
        #
        # @note
        #   Requires the `fs_chmod` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def chmod(*arguments)
          requires_method! :fs_chmod

          paths = arguments.pop.map { |path| join(path) }
          @leverage.fs_chmod(*arguments,paths)
        end

        #
        # Gathers statistics on a file or directory.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @return [File::Stat]
        #   The statistics on the file or directory.
        #
        # @see File::Stat.new
        #
        # @since 0.4.0
        #
        def stat(path)
          File::Stat.new(@leverage,join(path))
        end

        #
        # Compares the contents of two files.
        #
        # @param [String] path
        #   The path of the first file.
        #
        # @param [String] path
        #   The path of the second file.
        #
        # @return [Boolean]
        #   Specifies whether the two files are identical.
        #
        def compare(path,other_path)
          checksum1 = Digest::MD5.new
          open(path).each_block { |block| checksum1 << block }

          checksum2 = Digest::MD5.new
          open(other_path).each_block { |block| checksum2 << block }

          return checksum1 == checksum2
        end

        alias cmp compare

        #
        # Tests whether a file or directory exists.
        #
        # @param [String] path
        #   The path of the file or directory in question.
        #
        # @return [Boolean]
        #   Specifies whether the file or directory exists.
        #
        # @since 0.4.0
        #
        def exists?(path)
          begin
            stat(path)
            return true
          rescue Errno::ENOENT
            return false
          end
        end

        #
        # Tests whether a file exists.
        #
        # @param [String] path
        #   The path of the file in question.
        #
        # @return [Boolean]
        #   Specifies whether the file exists.
        #
        # @since 0.4.0
        #
        def file?(path)
          begin
            stat(path).file?
          rescue Errno::ENOENT
            return false
          end
        end

        #
        # Tests whether a directory exists.
        #
        # @param [String] path
        #   The path of the directory in question.
        #
        # @return [Boolean]
        #   Specifies whether the directory exists.
        #
        # @since 0.4.0
        #
        def directory?(path)
          begin
            stat(path).directory?
          rescue Errno::ENOENT
            return false
          end
        end

        #
        # Tests whether a FIFO pipe exists.
        #
        # @param [String] path
        #   The path of the FIFO pipe in question.
        #
        # @return [Boolean]
        #   Specifies whether the FIFO pipe exists.
        #
        # @since 0.4.0
        #
        def pipe?(path)
          begin
            stat(path).pipe?
          rescue Errno::ENOENT
            return false
          end
        end

        #
        # Tests whether a UNIX socket exists.
        #
        # @param [String] path
        #   The path of the UNIX socket in question.
        #
        # @return [Boolean]
        #   Specifies whether the UNIX socket exists.
        #
        # @since 0.4.0
        #
        def socket?(path)
          begin
            stat(path).socket?
          rescue Errno::ENOENT
            return false
          end
        end

        #
        # Tests whether a file is empty.
        #
        # @param [String] path
        #   The path of the file in question.
        #
        # @return [Boolean]
        #   Specifies whether the file is empty.
        #
        # @since 0.4.0
        #
        def zero?(path)
          begin
            stat(path).zero?
          rescue Errno::ENOENT
            return false
          end
        end

        alias empty? zero?

        #
        # Starts an interactive File System console.
        #
        # @since 0.4.0
        #
        def console
          UI::Shell.start(:prompt => 'fs>') do |shell,line|
            args = line.strip.split(' ')

            case args[0]
            when 'chdir', 'cd'
              chdir(args[1])
              print_info "Current working directory is now: #{@cwd}"
            when 'cwd', 'pwd'
              print_info "Current working directory: #{@cwd}"
            when 'read', 'cat'
              shell.write(read(args[1]))
            when 'hexdump'
              hexdump(args[1],shell)
            when 'copy'
              copy(args[1],args[2])
              print_info "Copied #{join(args[1])} -> #{join(args[2])}"
            when 'unlink', 'rm'
              unlink(args[1])
              print_info "Removed #{join(args[1])}"
            when 'rmdir'
              rmdir(args[1])
              print_info "Removed directory #{join(args[1])}"
            when 'move', 'mv'
              move(args[1],args[2])
              print_info "Moved #{join(args[1])} -> #{join(args[2])}"
            when 'link', 'ln'
              link(args[1],args[2])
              print_info "Linked #{join(args[1])} -> #{args[2]}"
            when 'chown'
              chown(*args[1..-1])
              print_info "Changed ownership of #{join(args[1])}"
            when 'chgrp'
              chgrp(*args[1..-1])
              print_info "Changed group ownership of #{join(args[1])}"
            when 'chmod'
              chmod(*args[1..-1])
              print_info "Changed permissions on #{join(args[1])}"
            when 'stat'
              stat(args[1])
            when 'help', '?'
              shell.puts(
                "cd DIR\t\t\t\tchanges the working directory to DIR",
                "cat PATH\t\t\treads data from the given PATH",
                "hexdump FILE\t\t\thexdumps the given FILE",
                "copy SRC DEST\t\t\tcopies a file from SRC to DEST",
                "rmdir DIR\t\t\tremoves the given DIR",
                "rm FILE\t\t\t\tremoves the given FILE",
                "move SRC DEST\t\t\tmoves a file or directory from SRC to DEST",
                "ln SRC DEST\t\t\tlinks a file or directory from SRC to DEST",
                "chown USER [GROUP] LIST...\tchanges ownership on one or more paths",
                "chgrp GROUP LIST...\t\tchanges group ownership on one or more paths",
                "chmod MODE LIST...\t\tchanges permissions on one or more paths",
                "stat PATH\t\t\tlists status information about the PATH",
                "help\t\t\t\tthis message"
              )
            else
              print_error "Unknown command #{args[0].dump}"
            end
          end
        end

      end
    end
  end
end
