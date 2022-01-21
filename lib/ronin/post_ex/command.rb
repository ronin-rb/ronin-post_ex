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

require 'fake_io'

module Ronin
  module PostEx
    #
    # The {Command} class represents commands being executed on remote
    # systems. The {Command} class wraps around the `shell_exec` method
    # defined in the API object.
    #
    class Command < Resource

      include FakeIO
      include Enumerable

      # The program name
      attr_reader :program

      # The arguments of the program
      attr_reader :arguments

      #
      # Creates a new Command.
      #
      # @param [#shell_exec] api
      #   The object controlling command execution.
      #
      # @param [String] program
      #   The program to run.
      #
      # @param [Array] arguments
      #   The arguments to run with.
      #
      # @raise [NotImplementedError]
      #   The API object does not define `shell_exec`.
      #
      def initialize(api,program,*arguments)
        unless api.respond_to?(:shell_exec)
          raise(NotImplementedError,"#{api.inspect} must define #shell_exec for #{self.class}")
        end

        @api       = api
        @program   = program
        @arguments = arguments

        super()
      end

      #
      # Reopens the command.
      #
      # @param [String] program
      #   The new program to run.
      #
      # @param [Array] arguments
      #   The new arguments to run with.
      #
      # @return [Command]
      #   The new command.
      #
      def reopen(program,*arguments)
        close

        @program = program
        @arguments = arguments

        return open
      end
      resource_method :reopen, [:shell_exec]

      #
      # Converts the command to a `String`.
      #
      # @return [String]
      #   The program name and arguments.
      #
      def to_s
        ([@program] + @arguments).join(' ')
      end

      #
      # Inspects the command.
      #
      # @return [String]
      #   The inspected command listing the program name and arguments.
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

      private

      #
      # Executes and opens the command for reading.
      #
      # @return [Enumerator]
      #   The enumerator that wraps around `shell_exec`.
      #
      def io_open
        @api.enum_for(:shell_exec,@program,*@arguments)
      end
      resource_method :open, [:shell_exec]

      #
      # Reads a line of output from the command.
      #
      # @return [String]
      #   A line of output.
      #
      # @raise [EOFError]
      #   The end of the output stream has been reached.
      #
      def io_read
        begin
          @fd.next
        rescue StopIteration
          raise(EOFError,"end of command")
        end
      end
      resource_method :read

      #
      # Writes data to the shell.
      #
      # @param [String] data
      #   The data to write to the shell.
      #
      # @return [Integer]
      #   The number of bytes writen.
      #
      def io_write(data)
        if @api.respond_to?(:shell_write)
          @api.shell_write(data)
        else
          raise(IOError,"#{@api.inspect} does not support writing to the shell")
        end
      end
      resource_method :write, [:shell_write]

    end
  end
end
