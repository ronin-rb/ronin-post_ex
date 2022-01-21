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

require 'ronin/post_ex/file/stat'
require 'ronin/post_ex/resource'

require 'fake_io'
require 'set'

module Ronin
  module PostEx
    #
    # The {File} class represents files on a remote system. {File} requires
    # the API object to define either `file_read` and/or `file_write`.
    # Additionally, {File} can optionally use the `file_open`, `file_close`,
    # `file_tell`, `file_seek` and `file_stat` methods.
    #
    class File < Resource

      include FakeIO

      #
      # Creates a new remote controlled File object.
      #
      # @param [#file_read, #file_write] api
      #   The API object that defines the `file_read` and `file_write` methods.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      def initialize(api,path,mode='r')
        @api  = api
        @path = path.to_s
        @mode = mode.to_s

        super()
      end

      #
      # Opens a file.
      #
      # @param [#file_read] api
      #   The object controlling remote files.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      # @yield [file]
      #   The given block will be passed the newly created file object.
      #   When the block has returned, the File object will be closed.
      #
      # @yieldparam [File]
      #   The newly created file object.
      #
      def self.open(api,path)
        io = new(api,path)

        if block_given?
          value = yield(io)

          io.close
          return value
        else
          return io
        end
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
      def seek(new_pos,whence=SEEK_SET)
        clear_buffer!

        if @api.respond_to?(:file_seek)
          @api.file_seek(@fd,new_pos,whence)
        end

        @pos = new_pos
      end
      resource_method :seek

      #
      # The current offset in the file.
      #
      # @return [Integer]
      #   The current offset in bytes.
      #
      def tell
        if @api.respond_to?(:file_tell)
          @pos = @api.file_tell(@fd)
        else
          @pos
        end
      end
      resource_method :tell

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
      #   The API object does not define `file_ioctl`.
      #
      def ioctl(command,argument)
        unless @api.respond_to?(:file_ioctl)
          raise(RuntimeError,"#{@api.inspect} does not define file_ioctl")
        end

        return @api.file_ioctl(command,argument)
      end
      resource_method :ioctl, [:file_ioctl]

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
      #   The API object does not define `file_fcntl`.
      #
      def fcntl(command,argument)
        unless @api.respond_to?(:file_fcntl)
          raise(RuntimeError,"#{@api.inspect} does not define file_fcntl")
        end

        return @api.file_fcntl(command,argument)
      end
      resource_method :fcntl, [:file_fcntl]

      #
      # Re-opens the file.
      #
      # @param [String] path
      #   The new path for the file.
      #
      # @return [File]
      #   The re-opened the file.
      #
      def reopen(path)
        close

        @path = path.to_s
        return open
      end
      resource_method :reopen

      #
      # The status information for the file.
      #
      # @return [Stat]
      #   The status information.
      #
      def stat
        File::Stat.new(@api,@path)
      end
      resource_method :stat, [:file_stat]

      #
      # Inspects the open file.
      #
      # @return [String]
      #   The inspected open file.
      #
      def inspect
        "#<#{self.class}:#{@path}>"
      end

      protected

      #
      # Attempts calling `file_open` from the API object to open the remote file.
      #
      # @return [Object]
      #   The file descriptor returned by `file_open`.
      #
      def io_open
        if @api.respond_to?(:file_open)
          @api.file_open(@path,@mode)
        else
          @path
        end
      end
      resource_method :open

      #
      # Reads a block from the remote file by calling `file_read` or
      # `file_readfile` from the API object.
      #
      # @return [String, nil]
      #   A block of data from the file.
      #
      # @raise [IOError]
      #   The API object does not define `file_read` or `file_readfile`.
      #
      def io_read
        if @api.respond_to?(:file_readfile)
          @eof = true
          @api.file_readfile(@path)
        elsif @api.respond_to?(:file_read)
          @api.file_read(@fd,@pos)
        else
          raise(IOError,"#{@api.inspect} does not support reading")
        end
      end
      resource_method :read, [:file_read]

      #
      # Writes data to the remote file by calling `file_write` from the
      # API object.
      #
      # @param [String] data
      #   The data to write.
      #
      # @return [Integer]
      #   The number of bytes writen.
      #
      # @raise [IOError]
      #   The API object does not define `file_write`.
      #
      def io_write(data)
        if @api.respond_to?(:file_write)
          @pos += @api.file_write(@fd,@pos,data)
        else
          raise(IOError,"#{@api.inspect} does not support writing to files")
        end
      end
      resource_method :write, [:file_write]

      #
      # Attempts calling `file_close` from the API object to close
      # the file.
      #
      def io_close
        if @api.respond_to?(:file_close)
          @api.file_close(@fd)
        end
      end
      resource_method :close

    end
  end
end
