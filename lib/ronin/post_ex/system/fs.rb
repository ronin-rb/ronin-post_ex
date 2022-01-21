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
require 'ronin/post_ex/remote_file'
require 'ronin/post_ex/captured_file'
require 'ronin/post_ex/file/stat'
require 'ronin/post_ex/remote_dir'

require 'hexdump'

module Ronin
  module PostEx
    class System < Resource
      #
      # Provides access to a system's a File System (FS).
      #
      # # Supported API Methods
      #
      # The File System resource uses the following control methods,
      # defined by the API object:
      #
      # * `fs_getcwd() -> String`
      # * `fs_chdir(path : String)`
      # * `fs_readlink(path : String) -> String`
      # * `fs_readdir(path : String) -> Array[String]`
      # * `fs_glob(pattern : String) -> Array[String]`
      # * `fs_mktemp(basename : String) -> String`
      # * `fs_mkdir(new_path : String)`
      # * `fs_copy(src : String, dest : String)`
      # * `fs_unlink(path : String)`
      # * `fs_rmdir(path : String)`
      # * `fs_move(src : String, dest : String)`
      # * `fs_link(src : String, dest : String)`
      # * `fs_chgrp(group : String, path : String)`
      # * `fs_chown(user : String, path : String)`
      # * `fs_chmod(mode : Integer, path : String)`
      # * `fs_compare(file1 : String, file2 : String) -> Boolean`
      # * `fs_stat(path : String) => Hash[Symbol, Object] | nil`
      #
      class FS < Resource

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        # @note
        #   May call the `fs_getcwd` method, if defined by the API object.
        #
        def getcwd
          if @api.respond_to?(:fs_getcwd)
            @cwd = @api.fs_getcwd
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
        #   May call the `fs_chdir` method, if defined by the API object.
        #
        def chdir(path)
          path = expand_path(path)
          old_cwd = @cwd

          @cwd = if @api.respond_to?(:fs_chdir)
                   @api.fs_chdir(path)
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
        def expand_path(path)
          if (@cwd && path[0,1] != '/')
            ::File.expand_path(::File.join(@cwd,path))
          else
            path
          end
        end

        #
        # Reads the full contents of a file.
        #
        # @param [String] path
        #   The path to the file.
        #
        # @return [String]
        #   The contents of the file.
        #
        # @note
        #   Requires the `fs_readfile` method be defined by the API object.
        #
        def readfile(path)
          @api.fs_readfile(path)
        end
        resource_method :readfile, [:fs_readfile]

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
        #   Requires the `fs_readlink` method be defined by the API object.
        #
        def readlink(path)
          @api.fs_readlink(path)
        end
        resource_method :readlink, [:fs_readlink]

        #
        # Opens a directory for reading.
        #
        # @param [String] path
        #   The path to the directory.
        #
        # @return [RemoteDir]
        #   The opened directory.
        #
        # @note
        #   Requires the `fs_readdir` method be defined by the API object.
        #
        def readdir(path)
          path    = expand_path(path)
          entries = @api.fs_readdir(path)

          return RemoteDir.new(path,entries)
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
        # @return [String] path
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
        #   Requires the `fs_glob` method be defined by the API object.
        #
        def glob(pattern,&block)
          path  = expand_path(pattern)
          paths = @api.fs_glob(pattern)

          paths.each(&block) if block
          return paths
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
        # @yieldparam [RemoteFile, CapturedFile] file
        #   The temporarily opened file. If {#api} defines the `file_open`, then
        #   a {RemoteFile} will be returned. If {#api} defines a `fs_readfile`
        #   method instead, than a {CapturedFile} will be returned.
        #
        # @return [RemoteFile, CapturedFile, nil]
        #   The newly opened file. If {#api} defines the `file_open`, then
        #   a {RemoteFile} will be returned. If {#api} defines a `fs_readfile`
        #   method instead, than a {CapturedFile} will be returned.
        #
        def open(path,&block)
          if @api.respond_to?(:file_open)
            RemoteFile.open(@api,expand_path(path),&block)
          else
            CapturedFile.new(expand_path(path),readfile(path),&block)
          end
        end
        resource_method :open

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
        # @yieldparam [RemoteFile] tempfile
        #   The temporarily opened tempfile.
        #
        # @return [RemoteFile, nil]
        #   The newly opened tempfile.
        #
        # @note
        #   Requires the `fs_mktemp` method be defined by the API object.
        #
        def tmpfile(basename,&block)
          open(@api.fs_mktemp(basename),&block)
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
        #   Requires the `fs_mkdir` method be defined by the API object.
        #
        def mkdir(path)
          @api.fs_mkdir(path)
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
        #   Requires the `fs_copy` method be defined by the API object.
        #
        def copy(path,new_path)
          @api.fs_copy(expand_path(path),expand_path(new_path))
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
        #   Requires the `fs_unlink` method be defined by the API object.
        #
        def unlink(path)
          @api.fs_unlink(expand_path(path))
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
        #   Requires the `fs_rmdir` method be defined by the API object.
        #
        def rmdir(path)
          @api.fs_rmdir(expand_path(path))
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
        #   Requires the `fs_move` method be defined by the API object.
        #
        def move(path,new_path)
          @api.fs_move(expand_path(path),expand_path(new_path))
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
        #   Requires the `fs_link` method be defined by the API object.
        #
        def link(path,new_path)
          @api.fs_link(path,new_path)
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
        #   Requires the `fs_chown` method be defined by the API object.
        #
        def chown(owner,path)
          user, group = owner

          chgrp(group,path) if group

          @api.fs_chown(user,expand_path(path))
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
        #   Requires the `fs_chgrp` method be defined by the API object.
        #
        def chgrp(group,path)
          @api.fs_chgrp(group,expand_path(path))
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
        #   Requires the `fs_chmod` method be defined by the API object.
        #
        def chmod(mode,path)
          @api.fs_chmod(mode,expand_path(path))
          return true
        end
        resource_method :chmod, [:fs_chmod]

        #
        # Gathers statistics on a file or directory.
        #
        # @param [String] path
        #   The path of the file or directory.
        #
        # @return [RemoteFile::Stat]
        #   The statistics on the file or directory.
        #
        # @see RemoteFile::Stat#initialize
        #
        def stat(path)
          RemoteFile::Stat.new(@api,expand_path(path))
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
        #   Requires the `fs_compare` method be defined by the API object.
        #
        def compare(path,other_path)
          @api.fs_compare(path,other_path)
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

      end
    end
  end
end
