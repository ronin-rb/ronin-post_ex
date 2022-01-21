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
require 'ronin/post_ex/file'
require 'ronin/post_ex/file/stat'
require 'ronin/post_ex/dir'
require 'ronin/post_ex/shells/fs'
require 'ronin/ui/shell'

require 'hexdump'

module Ronin
  module PostEx
    module Resources
      #
      # Controls the resources of a File System.
      #
      # # Supported Control Methods
      #
      # The File System resource uses the following control methods,
      # defined by the controller object:
      #
      # * `fs_getcwd() # => String`
      # * `fs_chdir(path)`
      # * `fs_readlink(path) # => String`
      # * `fs_readdir(path) # => [String, ...]`
      # * `fs_glob(pattern) { |path| ... }`
      # * `fs_mktemp(basename) # => String`
      # * `fs_mkdir(new_path)`
      # * `fs_copy(src,dest)`
      # * `fs_unlink(path)`
      # * `fs_rmdir(path)`
      # * `fs_move(src,dest)`
      # * `fs_link(src,dest)`
      # * `fs_chgrp(group,path)`
      # * `fs_chown(user,path)`
      # * `fs_chmod(mode,path)`
      # * `fs_compare(file1,file2) # => Boolean`
      #
      # @since 1.0.0
      #
      class FS < Resource

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        # @note
        #   May call the `fs_getcwd` method, if defined by the controller
        #   object.
        #
        def getcwd
          if @controller.respond_to?(:fs_getcwd)
            @cwd = @controller.fs_getcwd
          end

          return @cwd
        end
        resource_method :getcwd, [:fs_getcwd]

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
        #   May call the `fs_chdir` method, if defined by the controller
        #   object.
        #
        def chdir(path)
          path = join(path)
          old_cwd = @cwd

          @cwd = if @controller.respond_to?(:fs_chdir)
                   @controller.fs_chdir(path)
                 else
                   path
                 end

          if block_given?
            yield @cwd
            chdir(old_cwd)
          end

          return @cwd
        end
        resource_method :chdir

        #
        # Joins the path with the current working directory.
        #
        # @param [String] path
        #   The path to join.
        #
        # @return [String]
        #   The absolute path.
        #
        def join(path)
          if (@cwd && path[0,1] != '/')
            ::File.expand_path(::File.join(@cwd,path))
          else
            path
          end
        end

        #
        # Reads the destination of a link.
        #
        # @param [String] path
        #   The path to the link.
        #
        # @return [String]
        #   The destination of the link.
        #
        # @note
        #   Requires the `fs_readlink` method be defined by the controller
        #   object.
        #
        def readlink(path)
          @controller.fs_readlink(path)
        end
        resource_method :readlink, [:fs_readlink]

        #
        # Opens a directory for reading.
        #
        # @param [String] path
        #   The path to the directory.
        #
        # @return [Dir]
        #   The opened directory.
        #
        # @note
        #   Requires the `fs_readdir` method be defined by the controller
        #   object.
        #
        def readdir(path)
          path    = join(path)
          entries = @controller.fs_readdir(path)

          return Dir.new(path,entries)
        end
        resource_method :readdir, [:fs_readdir]

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
        #   Requires the `fs_glob` method be defined by the controller
        #   object.
        #
        def glob(pattern,&block)
          path = join(pattern)

          if block
            @controller.fs_glob(pattern,&block)
          else
            @controller.enum_for(:fs_glob,pattern).to_a
          end
        end
        resource_method :glob, [:fs_glob]

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
        def open(path,&block)
          File.open(@controller,join(path),&block)
        end
        resource_method :open

        #
        # Reads the contents of a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @return [String]
        #   The contents of the file.
        #
        def read(path)
          open(path).read
        end
        resource_method :read, [:fs_read]

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
        def hexdump(path,output=STDOUT)
          open(path) { |file| Hexdump.dump(file,output: output) }
        end
        resource_method :hexdump, [:fs_read]

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
        def write(path,data)
          open(path) { |file| file.write(data) }
        end
        resource_method :write, [:fs_write]

        #
        # Touches a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @return [nil]
        #
        def touch(path)
          open(path) { |file| file << '' }
        end
        resource_method :touch, [:fs_write]

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
        #   Requires the `fs_mktemp` method be defined by the controller
        #   object.
        #
        def tmpfile(basename,&block)
          open(@controller.fs_mktemp(basename),&block)
        end
        resource_method :tmpfile, [:fs_mktemp]

        #
        # Creates a directory.
        #
        # @param [String] path
        #   The path of the directory.
        #
        # @return [true]
        #   Specifies that the directory was successfully created.
        #
        # @note
        #   Requires the `fs_mkdir` method be defined by the controller
        #   object.
        #
        def mkdir(path)
          @controller.fs_mkdir(path)
          return true
        end
        resource_method :mkdir, [:fs_mkdir]

        #
        # Copies a file.
        #
        # @param [String] path
        #   The path of the file to copy.
        #
        # @param [String] new_path
        #   The destination path to copy to.
        #
        # @return [true]
        #   Specifies that the file was successfully copied.
        #
        # @note
        #   Requires the `fs_copy` method be defined by the controller
        #   object.
        #
        def copy(path,new_path)
          @controller.fs_copy(join(path),join(new_path))
          return true
        end
        resource_method :copy, [:fs_copy]

        #
        # Unlinks a file.
        #
        # @param [String] path
        #   The path of the file.
        #
        # @return [true]
        #   Specifies that the file was successfully removed.
        #
        # @note
        #   Requires the `fs_unlink` method be defined by the controller
        #   object.
        #
        def unlink(path)
          @controller.fs_unlink(join(path))
          return true
        end
        resource_method :unlink, [:fs_unlink]

        alias rm unlink

        #
        # Removes a directory.
        #
        # @param [String] path
        #   The path of the directory.
        #
        # @return [true]
        #   Specifies that the directory was successfully removed.
        #
        # @note
        #   Requires the `fs_rmdir` method be defined by the controller
        #   object.
        #
        def rmdir(path)
          @controller.fs_rmdir(join(path))
          return true
        end
        resource_method :rmdir, [:fs_rmdir]

        #
        # Moves a file or directory.
        #
        # @param [String] path
        #   The path of the file or directory to be moved.
        #
        # @param [String] new_path
        #   The destination path for the file or directory to be moved to.
        #
        # @return [true]
        #   Specifies that the file or directory was successfully moved.
        #
        # @note
        #   Requires the `fs_move` method be defined by the controller
        #   object.
        #
        def move(path,new_path)
          @controller.fs_move(join(path),join(new_path))
          return true
        end
        resource_method :move, [:fs_move]

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
        # @return [true]
        #   Specifies that the symbolic link was successfully created.
        #
        # @note
        #   Requires the `fs_link` method be defined by the controller
        #   object.
        #
        def link(path,new_path)
          @controller.fs_link(path,new_path)
          return true
        end
        resource_method :link, [:fs_link]

        #
        # Changes ownership of a file or directory.
        #
        # @param [user,(user,group)] owner
        #   the user and/or group that will own the file or directory.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @return [true]
        #   Specifies that the ownership was successfully changed.
        #
        # @example
        #   exploit.fs.chown('www', 'one.html')
        #
        # @example
        #   exploit.fs.chown(['alice', 'users'], 'one.html')
        #
        # @note
        #   Requires the `fs_chown` method be defined by the controller
        #   object.
        #
        def chown(owner,path)
          user, group = owner

          chgrp(group,path) if group

          @controller.fs_chown(user,join(path))
          return true
        end
        resource_method :chown, [:fs_chown]

        #
        # Changes group ownership on one or more files or directories.
        #
        # @param [String] group
        #   The group that will own the file or directory.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @return [true]
        #   Specifies that the group ownership was successfully changed.
        #
        # @example
        #   exploit.fs.chgrp('www', 'one.html')
        #
        # @note
        #   Requires the `fs_chgrp` method be defined by the controller
        #   object.
        #
        def chgrp(group,path)
          @controller.fs_chgrp(group,join(path))
          return true
        end
        resource_method :chgrp, [:fs_chgrp]

        #
        # Changes permissions on one or more file or directorie.
        #
        # @param [Integer] mode
        #   The new mode for the file or directory.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @return [true]
        #   Specifies that the permissions were successfully changed.
        #
        # @example
        #   exploit.fs.chmod(0665, 'one.html')
        #
        # @note
        #   Requires the `fs_chmod` method be defined by the controller
        #   object.
        #
        def chmod(mode,path)
          @controller.fs_chmod(mode,join(path))
          return true
        end
        resource_method :chmod, [:fs_chmod]

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
        def stat(path)
          File::Stat.new(@controller,join(path))
        end
        resource_method :stat, [:fs_stat]

        #
        # Compares the contents of two files.
        #
        # @param [String] path
        #   The path of the first file.
        #
        # @param [String] other_path
        #   The path of the second file.
        #
        # @return [Boolean]
        #   Specifies whether the two files are identical.
        #
        # @note
        #   Requires the `fs_compare` method be defined by the controller
        #   object.
        #
        def compare(path,other_path)
          @controller.fs_compare(path,other_path)
        end
        resource_method :compare, [:fs_compare]

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
        def exists?(path)
          begin
            stat(path)
            return true
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :exists?, [:fs_stat]

        #
        # Tests whether a file exists.
        #
        # @param [String] path
        #   The path of the file in question.
        #
        # @return [Boolean]
        #   Specifies whether the file exists.
        #
        def file?(path)
          begin
            stat(path).file?
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :file?, [:fs_stat]

        #
        # Tests whether a directory exists.
        #
        # @param [String] path
        #   The path of the directory in question.
        #
        # @return [Boolean]
        #   Specifies whether the directory exists.
        #
        def directory?(path)
          begin
            stat(path).directory?
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :directory?, [:fs_stat]

        #
        # Tests whether a FIFO pipe exists.
        #
        # @param [String] path
        #   The path of the FIFO pipe in question.
        #
        # @return [Boolean]
        #   Specifies whether the FIFO pipe exists.
        #
        def pipe?(path)
          begin
            stat(path).pipe?
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :pipe?, [:fs_stat]

        #
        # Tests whether a UNIX socket exists.
        #
        # @param [String] path
        #   The path of the UNIX socket in question.
        #
        # @return [Boolean]
        #   Specifies whether the UNIX socket exists.
        #
        def socket?(path)
          begin
            stat(path).socket?
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :socket?, [:fs_stat]

        #
        # Tests whether a file is empty.
        #
        # @param [String] path
        #   The path of the file in question.
        #
        # @return [Boolean]
        #   Specifies whether the file is empty.
        #
        def zero?(path)
          begin
            stat(path).zero?
          rescue Errno::ENOENT
            return false
          end
        end
        resource_method :zero?, [:fs_stat]

        alias empty? zero?

        #
        # Starts an interactive File System console.
        #
        def console
          Shells::FS.start(self)
        end

      end
    end
  end
end