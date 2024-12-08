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

require_relative 'resource'

require 'fake_io'

module Ronin
  module PostEx
    #
    # The {RemoteProcess} class represents a command being executed on a remote
    # system. The {RemoteProcess} class wraps around the `process_popen` and
    # `process_read`, `process_write`, and `process_close` methods defined in
    # the API object.
    #
    class RemoteProcess < Resource

      include FakeIO
      include Enumerable

      # The command string.
      #
      # @return [String]
      attr_reader :command

      #
      # Creates a new remote process.
      #
      # @param [Sessions::Session] session
      #   The object controlling command execution.
      #
      # @param [String] command
      #   The command to run.
      #
      # @raise [NotImplementedError]
      #   The session object does not define `process_popen`.
      #
      def initialize(session,command)
        unless session.respond_to?(:process_popen)
          raise(NotImplementedError,"#{session.inspect} must define #process_popen for #{self.class}")
        end

        @session = session
        @command = command

        super()
      end

      #
      # Reopens the command.
      #
      # @param [String] command
      #   The new command to run.
      #
      # @return [RemoteProcess]
      #   The new command.
      #
      def reopen(command)
        close

        @command = command

        return open
      end
      resource_method :reopen, [:process_popen]

      #
      # Converts the command to a `String`.
      #
      # @return [String]
      #   The process'es command.
      #
      def to_s
        @command
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
      #   The enumerator that wraps around `process_popen`.
      #
      def io_open
        @session.enum_for(:process_popen,@command)
      end
      resource_method :open, [:process_popen]

      # Default block size to read process output with.
      BLOCK_SIZE = 4096

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
        if @session.respond_to?(:process_read)
          @session.process_write(@fd,BLOCK_SIZE)
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
      #   The number of bytes written.
      #
      def io_write(data)
        if @session.respond_to?(:process_write)
          @session.process_write(@fd,data)
        else
          raise(IOError,"#{@session.inspect} does not support writing to the shell")
        end
      end
      resource_method :write, [:process_write]

      #
      # Attempts calling `process_close` from the API object to close
      # the file.
      #
      # @note
      #   This method may use the `process_close` method, if {#session} defines it.
      #
      def io_close
        if @session.respond_to?(:process_close)
          @session.process_close(@fd)
        end
      end
      resource_method :close

    end
  end
end
