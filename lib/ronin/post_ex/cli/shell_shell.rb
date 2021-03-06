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

require 'ronin/core/cli/shell'

module Ronin
  module PostEx
    module CLI
      #
      # A shell for {System::Shell}.
      #
      class ShellShell < Core::CLI::Shell

        prompt_sigil '$'

        #
        # Initializes the shell.
        #
        # @param [System::Shell] shell
        #   The shell resource.
        #
        def initialize(shell, **kwargs)
          super(**kwargs)

          @shell = shell
        end

        #
        # Executes a command and prints it's output.
        #
        # @param [String] command
        #   The command string.
        #
        def exec(command)
          @shell.command(command).each_chunk do |chunk|
            write(chunk)
          end
        end

      end
    end
  end
end
