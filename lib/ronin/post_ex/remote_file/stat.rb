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
        #
        # @return [String]
        attr_reader :path

        # The size of the file (in bytes)
        #
        # @return [Integer]
        attr_reader :size

        # The number of native file-system blocks
        #
        # @return [Integer]
        attr_reader :blocks

        # The native file-system block size.
        #
        # @return [Integer]
        attr_reader :blocksize

        # The Inode number
        #
        # @return [Integer]
        attr_reader :inode

        # The number of hard links to the file
        #
        # @return [Integer]
        attr_reader :nlinks

        # The mode of the file
        #
        # @return [Integer]
        attr_reader :mode

        # The owner's UID of the file.
        #
        # @return [Integer]
        attr_reader :uid

        # The owner's GID of the file.
        #
        # @return [Integer]
        attr_reader :gid

        # The access time of the file.
        #
        # @return [Time, nil]
        attr_reader :atime

        # The creation time of the file.
        #
        # @return [Time]
        attr_reader :ctime

        # The modification time of the file.
        #
        # @return [Time]
        attr_reader :mtime

        #
        # Creates a new File Stat object.
        #
        # @param [Sessions::Session##fs_stat] session
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
        #   This method requires `session` define the `fs_stat` API method.
        #
        def initialize(session, path: nil, fd: nil)
          if path
            unless session.respond_to?(:fs_stat)
              raise(NotImplementedError,"#{session.inspect} does not define #fs_stat")
            end
          elsif fd
            unless session.respond_to?(:file_stat)
              raise(NotImplementedError,"#{session.inspect} does not define #file_stat")
            end
          else
            raise(ArgumentError,"#{self.class}#initialize must be given either the path: or fd: keyword argument")
          end

          @session = session
          @path    = path.to_s

          unless (stat = @session.fs_stat(@path))
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
