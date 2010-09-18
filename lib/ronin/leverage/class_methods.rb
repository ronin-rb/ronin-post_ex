#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'set'

module Ronin
  module Leverage
    module ClassMethods
      #
      # The services provided by the session.
      #
      # @return [Set<Symbol>]
      #   The service names.
      #
      # @since 0.4.0
      #
      def leverages
        @leverages ||= Set[]
      end

      #
      # Determines if the class leverages a specific resource.
      #
      # @param [Symbol]
      #   The resource name.
      #
      # @return [Boolean]
      #   Specifies whether the class leverages the resource.
      #
      # @since 0.4.0
      #
      def leverages?(name)
        self.leverages.include?(name.to_sym)
      end

      protected

      #
      # Specifies that the class will leverage a resource.
      #
      # @param [Symbol] name
      #   The name of the resource to leverage.
      #
      # @since 0.4.0
      #
      def leverage(name)
        name = name.to_sym

        define_method(name) { self.leveraged[name] }

        self.leverages << name
      end
    end
  end
end
