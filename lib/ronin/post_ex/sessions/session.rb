# frozen_string_literal: true
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

require 'ronin/post_ex/system'

module Ronin
  module PostEx
    module Sessions
      class Session

        #
        # The session name.
        #
        # @return [String]
        #
        # @raise [NotImplementedError]
        #   The session class did not set `@name`.
        #
        def name
          @name || raise(NotImplementedError,"#{self.class}#name was not set")
        end

        #
        # The remote system connected to the session.
        #
        # @return [System]
        #
        def system
          @system ||= System.new(self)
        end

        #
        # Closes the session.
        #
        # @abstract
        #
        def close
        end

        #
        # Converts the session to a String.
        #
        # @return [String]
        #   The session's {#name}.
        #
        def to_s
          name
        end

      end
    end
  end
end
