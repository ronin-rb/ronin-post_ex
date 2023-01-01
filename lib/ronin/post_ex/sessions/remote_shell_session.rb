# frozen_string_literal: true
#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/post_ex/sessions/shell_session'

module Ronin
  module PostEx
    module Sessions
      #
      # Session base class for all other remote shell sessions.
      #
      class RemoteShellSession < ShellSession

        #
        # Initializes the remote shell session.
        #
        # @param [TCPSocket, UDPSocket] socket
        #   The underlying socket for the remote shell session.
        #
        def initialize(socket)
          super(socket)

          addrinfo = socket.remote_address

          @name = "#{addrinfo.ip_address}:#{addrinfo.ip_port}"
        end

      end
    end
  end
end
