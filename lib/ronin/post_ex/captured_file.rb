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

require 'stringio'

module Ronin
  module PostEx
    #
    # Represents a file that was fully read.
    #
    class CapturedFile < StringIO

      # The path to the read file.
      #
      # @return [String]
      attr_reader :path

      #
      # Initializes the read file.
      #
      # @param [String] path
      #   The path of the captured file.
      #
      # @param [String] contents
      #   The contents of the captured file.
      #
      def initialize(path,contents)
        @path = path

        super(contents)
      end

    end
  end
end
