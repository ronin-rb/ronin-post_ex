# frozen_string_literal: true
#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2024 Hal Brodigan (postmodern.mod3 at gmail.com)
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

module Ronin
  module PostEx
    #
    # The {RemoteDir} class represents directories on a remote system.
    #
    class RemoteDir

      include Enumerable

      # The path of the directory
      attr_reader :path

      # The current position in the open directory.
      #
      # @return [Integer]
      attr_reader :pos

      #
      # Creates a new Dir object.
      #
      # @param [String] path
      #   The path to the directory.
      #
      # @param [Array<String>] entries
      #   The entries of the directory.
      #
      def initialize(path,entries=[])
        @path    = path
        @entries = entries
        @pos     = 0
        @closed  = false
      end

      #
      # Returns the position in the opened directory.
      #
      # @return [Integer]
      #   The position of the opened directory.
      #
      # @raise [IOError]
      #   The directory is closed.
      #
      def tell
        if @closed
          raise(IOError,"closed directory")
        end

        return @pos
      end

      #
      # Rewinds the opened directory.
      #
      # @return [Dir]
      #
      # @raise [IOError]
      #   The directory is closed.
      #
      def rewind
        if @closed
          raise(IOError,"closed directory")
        end

        @pos = 0
        return self
      end

      #
      # Sets the position within the open directory.
      #
      # @param [Integer] new_pos
      #   The new position within the open directory.
      #
      # @return [Dir]
      #
      # @raise [Errno::EINVAL]
      #   The new position was out of bounds.
      #
      # @raise [IOError]
      #   The directory is closed.
      #
      def seek(new_pos)
        if @closed
          raise(IOError,"closed directory")
        end

        if (new_pos < 0) || (new_pos >= @entries.length)
          raise(Errno::EINVAL,"invalid seek position")
        end

        @pos = new_pos
        return self
      end

      #
      # Iterates through the entries within the directory.
      #
      # @yield [entry]
      #   The given block will be passed each entry.
      #
      # @yieldparam [String] entry
      #   An entry from the directory.
      #
      # @return [Enumerator]
      #   An enumerator will be returned if no block is given.
      #
      # @raise [IOError]
      #   The directory is closed.
      #
      def each
        return enum_for(__method__) unless block_given?

        if @closed
          raise(IOError,"closed directory")
        end

        @pos = 0

        @entries.each do |entry|
          yield entry
          @pos += 1
        end

        return self
      end

      #
      # Reads the next entry from the directory.
      #
      # @return [String, nil]
      #   The next entry from the opened directory.
      #   If all entries have been read, `nil` is returned.
      #
      # @raise [IOError]
      #   The directory is closed.
      #
      def read
        if @closed
          raise(IOError,"closed directory")
        end

        if @pos < @entries.length
          next_entry = @entries[@pos]

          @pos += 1
          return next_entry
        end
      end

      #
      # Closes the opened directory.
      #
      def close
        @closed = true
        return nil
      end

      #
      # Inspects the directory.
      #
      # @return [String]
      #   The inspected directory.
      #
      def inspect
        "<#{self.class}:#{@path}>"
      end

    end
  end
end
