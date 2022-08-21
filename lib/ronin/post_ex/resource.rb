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

module Ronin
  module PostEx
    #
    # A base-class for all Post-Exploitation Resources.
    #
    class Resource

      # The object providing control of the Resource
      #
      # @return [Object]
      attr_reader :api

      #
      # Creates a new Resource.
      #
      # @param [Object] api
      #   The object controlling the Resource.
      #
      def initialize(api)
        @api = api
      end

      #
      # Determines whether the API object supports the Resource method(s).
      #
      # @param [Array<Symbol>] method_names
      #   The name of the Resource method.
      #
      # @return [Boolean]
      #   Specifies whether the API object supports the method.
      #
      # @example
      #   fs.supports?(:read, :write)
      #   # => true
      #
      # @api public
      #
      def supports?(*method_names)
        method_names.all? do |method_name|
          method_name = method_name.to_sym
          api_methods = self.class.resource_methods[method_name]

          api_methods && api_methods.all? { |api_method|
            @api.respond_to?(api_method)
          }
        end
      end

      #
      # Determines which Resource methods are supported by the controlling
      # object.
      #
      # @return [Array<Symbol>]
      #   The names of the supported Resource methods.
      #
      def supports
        self.class.resource_methods.keys.select do |method_name|
          supports?(method_name)
        end
      end

      #
      # Allows resources to spawn interactive consoles.
      #
      # @abstract
      #
      def interact
        raise(NotImplementedError,"#{self.class} does not provide a console")
      end

      private

      #
      # The defined Resource methods.
      #
      # @return [Hash{Symbol => Array<Symbol>}]
      #   The names of the Resource methods and their required API methods.
      #
      # @api semipublic
      #
      def self.resource_methods
        @resource_methods ||= {}
      end

      #
      # Specifies that a Resource method requires certain methods define by the
      # API object.
      #
      # @param [Symbol] method_name
      #   The name of the Resource method.
      #
      # @param [Array<Symbol>] control_methods
      #   The methods that must be defined by the API object.
      #
      # @api semipublic
      #
      def self.resource_method(method_name,control_methods=[])
        resource_methods[method_name.to_sym] = control_methods.map(&:to_sym)
      end

      #
      # Requires that the controlling object define the given method.
      #
      # @param [Symbol] name
      #   The name of the method that is required.
      #
      # @return [true]
      #   The method is defined.
      #
      # @raise [NotImplementedError]
      #   The method is not defined by the controlling object.
      #
      def requires_method!(name)
        unless @api.respond_to?(name)
          raise(NotImplementedError,"#{@api.inspect} does not define #{name}")
        end

        return true
      end

    end
  end
end
