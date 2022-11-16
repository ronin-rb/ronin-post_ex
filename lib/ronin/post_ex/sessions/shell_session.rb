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

require 'ronin/post_ex/sessions/session'

require 'base64'

module Ronin
  module PostEx
    module Sessions
      #
      # Base class for all interactive shell based post-exploitation sessions.
      #
      class ShellSession < Session

        # The IO object used to communicate with the shell.
        #
        # @return [TCPSocket, IO]
        #
        # @api private
        attr_reader :io

        #
        # Initializes the shell session.
        #
        # @param [TCPSocet, IO] io
        #   The IO object used to communicate with the shell.
        #
        def initialize(io)
          @io = io
        end

        # Deliminator line to indicate the beginning and end of output
        DELIMINATOR = '---'

        #
        # Executes a shell command and returns it's output.
        #
        # @param [String] command
        #   The shell command to execute.
        #
        # @return [String]
        #   The output of the shell command.
        #
        def shell_exec(command)
          @io.write("echo #{DELIMINATOR}; #{command} 2>/dev/null | base64; echo #{DELIMINATOR}\n")

          # consume any leading output before the command output
          while (line = @io.gets)
            if line.chomp == DELIMINATOR
              break
            end
          end

          output = String.new

          while (line = @io.gets)
            if line.chomp == DELIMINATOR
              break
            end

            output << line
          end

          return Base64.decode64(output)
        end

        #
        # Closes the remote shell.
        #
        def close
          @io.close
        end

      end
    end
  end
end
