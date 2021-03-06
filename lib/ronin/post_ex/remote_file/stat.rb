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

module Ronin
  module PostEx
    class RemoteFile < Resource
      #
      # Represents the status information of a remote file. The {Stat} class
      # using the `fs_stat` or `file_stat` method defined by the API object to
      # request the remote status information.
      #
      # ## Supported API Methods
      #
      # * `file_stat(fd : Integer) -> Hash[Symbol, Object] | nil`
      # * `fs_stat(path : String) -> Hash[Symbol, Object] | nil`
      #
      class Stat

        # The path of the file
        attr_reader :path

        # The size of the file (in bytes)
        attr_reader :size

        # The number of native file-system blocks
        attr_reader :blocks

        # The native file-system block size.
        attr_reader :blocksize

        # The Inode number
        attr_reader :inode

        # The number of hard links to the file
        attr_reader :nlinks

        # The mode of the file
        attr_reader :mode

        #
        # Creates a new File Stat object.
        #
        # @param [#fs_stat] api
        #   The object controlling file-system stat.
        #
        # @param [String] path
        #   The path to stat.
        #
        # @param [Integer] fd
        #   The file description to stat.
        #
        # @raise [ArgumentError]
        #   Neither the `path:` or `fd:` keyword arguments were given.
        #
        # @raise [NotImplementedError]
        #   The leveraging object does not define `fs_stat` or `file_stat`
        #   needed by {Stat}.
        #
        # @raise [Errno::ENOENT]
        #   The remote file does not exist.
        #
        # @note
        #   This method requires `api` define the `fs_stat` API method.
        #
        def initialize(api,path: nil, fd: nil)
          if path
            unless api.respond_to?(:fs_stat)
              raise(NotImplementedError,"#{api.inspect} does not define #fs_stat")
            end
          elsif fd
            unless api.respond_to?(:file_stat)
              raise(NotImplementedError,"#{api.inspect} does not define #file_stat")
            end
          else
            raise(ArgumentError,"#{self.class}#initialize must be given either the path: or fd: keyword argument")
          end

          @api  = api
          @path = path.to_s

          unless (stat = @api.fs_stat(@path))
            raise(Errno::ENOENT,"No such file or directory #{@path.dump}")
          end

          @size      = stat[:size]
          @blocks    = stat[:blocks]
          @blocksize = stat[:blocksize]
          @inode     = stat[:inode]
          @nlinks    = stat[:nlinks]

          @mode = stat[:mode]
          @uid  = stat[:uid]
          @gid  = stat[:gid]

          @atime = stat[:atime]
          @ctime = stat[:ctime]
          @mtime = stat[:mtime]
        end

        alias ino inode
        alias blksize blocksize

        #
        # Determines whether the file has zero size.
        #
        # @return [Boolean]
        #   Specifies whether the file has zero size.
        #
        def zero?
          @size == 0
        end

      end
    end
  end
end
