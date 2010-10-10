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

require 'ronin/leverage/file/stat'
require 'ronin/leverage/io'

module Ronin
  module Leverage
    #
    # The {File} class represents files on a remote system. {File} requires
    # the leveraging object to define either `fs_read` and/or `fs_write`.
    # Additionally, {File} can optionally use the `fs_open`, `fs_close`,
    # `fs_tell`, `fs_seek` and `fs_stat` methods.
    #
    class File < IO

      #
      # Creates a new levered File object.
      #
      # @param [#fs_read] leverage
      #   The object leveraging remote files.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      # @since 0.4.0
      #
      def initialize(leverage,path)
        @leverage = leverage
        @path = path.to_s

        super()
      end

      #
      # Sets the position in the file to read.
      #
      # @param [Integer] new_pos
      #   The new position to read from.
      #
      # @return [Integer]
      #   The new position within the file.
      #
      # @since 0.4.0
      #
      def seek(new_pos,whence=SEEK_SET)
        clear_buffer!

        if @leverage.respond_to?(:fs_seek)
          @leverage.fs_seek(@fd,new_pos,whence)
        end

        @pos = new_pos
      end

      #
      # The current offset in the file.
      #
      # @return [Integer]
      #   The current offset in bytes.
      #
      # @since 0.4.0
      #
      def tell
        if @leverage.respond_to?(:fs_tell)
          @pos = @leverage.fs_tell(@fd)
        else
          @pos
        end
      end

      #
      # Executes a low-level command to control or query the IO stream.
      #
      # @param [String, Array<Integer>] command
      #   The IOCTL command.
      #
      # @param [Object] argument
      #   Argument of the command.
      #
      # @raise [RuntimeError]
      #   The leveraging object does not define `fs_ioctl`.
      #
      # @since 0.4.0
      #
      def ioctl(command,argument)
        unless @leverage.respond_to?(:fs_ioctl)
          raise(RuntimeError,"#{@leverage.inspect} does not define fs_ioctl")
        end

        return @leverage.fs_ioctl(command,argument)
      end

      #
      # Executes a low-level command to control or query the file stream.
      #
      # @param [String, Array<Integer>] command
      #   The FCNTL command.
      #
      # @param [Object] argument
      #   Argument of the command.
      #
      # @raise [RuntimeError]
      #   The leveraging object does not define `fs_fcntl`.
      #
      # @since 0.4.0
      #
      def fcntl(command,argument)
        unless @leverage.respond_to?(:fs_fcntl)
          raise(RuntimeError,"#{@leverage.inspect} does not define fs_fcntl")
        end

        return @leverage.fs_fcntl(command,argument)
      end

      #
      # Re-opens the file.
      #
      # @param [String] path
      #   The new path for the file.
      #
      # @return [File]
      #   The re-opened the file.
      #
      # @since 0.4.0
      #
      def reopen(path)
        close

        @path = path.to_s

        return open
      end

      #
      # The status information for the file.
      #
      # @return [Stat]
      #   The status information.
      #
      # @since 0.4.0
      #
      def stat
        File::Stat.new(@leverage,@path)
      end

      #
      # Inspects the open file.
      #
      # @return [String]
      #   The inspected open file.
      #
      # @since 0.4.0
      #
      def inspect
        "#<#{self.class}:#{@path}>"
      end

      protected

      #
      # Attempts calling `fs_open` from the leveraging object to open
      # the remote file.
      #
      # @return [Object]
      #   The file descriptor returned by `fs_open`.
      #
      # @since 0.4.0
      #
      def io_open
        if @leverage.respond_to?(:fs_open)
          @leverage.fs_open(@path)
        else
          @path
        end
      end

      #
      # Reads a block from the remote file by calling `fs_read` from the
      # leveraging object.
      #
      # @return [String, nil]
      #   A block of data from the file.
      #
      # @raise [IOError]
      #   The leveraging object does not define `fs_read`.
      #
      # @since 0.4.0
      #
      def io_read
        if @leverage.respond_to?(:fs_read)
          @leverage.fs_read(@fd,@pos)
        else
          raise(IOError,"#{@leverage.inspect} does not support reading")
        end
      end

      #
      # Writes data to the remote file by calling `fs_write` from the
      # leveraging object.
      #
      # @param [String] data
      #   The data to write.
      #
      # @return [Integer]
      #   The number of bytes writen.
      #
      # @raise [IOError]
      #   The leveraging object does not define `fs_write`.
      #
      # @since 0.4.0
      #
      def io_write(data)
        if @leverage.respond_to?(:fs_write)
          @leverage.fs_write(@fd,@pos,data)
        else
          raise(IOError,"#{@leverage.inspect} does not support writing to files")
        end
      end

      #
      # Attempts calling `fs_close` from the leveraging object to close
      # the file.
      #
      # @since 0.4.0
      #
      def io_close
        if @leverage.respond_to?(:fs_close)
          @leverage.fs_close(@fd)
        end
      end

    end
  end
end
