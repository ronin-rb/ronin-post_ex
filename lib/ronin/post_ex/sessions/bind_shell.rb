# frozen_string_literal: true
#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2026 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require_relative 'remote_shell_session'

require 'socket'

module Ronin
  module PostEx
    module Sessions
      #
      # Session class for interacting with bind shells.
      #
      # ## Examples
      #
      #     session = Ronin::PostEx::Sessions::BindShell.connect(host,port)
      #     system  = session.system
      #     
      #     system.shell.ls('/')
      #     # => "..."
      #
      class BindShell < RemoteShellSession

        #
        # Connects to a remote bind shell.
        #
        # @param [String] host
        #   The host to connect to.
        #
        # @param [Integer] port
        #   The port to connect to.
        #
        # @return [BindShell]
        #   The new bind shell session.
        #
        def self.connect(host,port)
          new(TCPSocket.new(host,port))
        end

      end
    end
  end
end
