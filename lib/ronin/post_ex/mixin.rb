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

require 'ronin/post_ex/resources'

module Ronin
  module PostEx
    #
    # Classes or objects can include {Mixin} and define a POSIX-style
    # API to control exploited Resources. {Resources} contains classes that
    # provide convience methods for controlling resources. In turn, these
    # convience methods call methods defined in the object which controls
    # said Resource.
    #
    # For example, the {PostEx::Resources::FS#mkdir} method relies on
    # the `fs_mkdir` method to handle the making of the directory:
    #
    #       #
    #       # Injects a `mkdir` command.
    #       #
    #       def fs_mkdir(path)
    #         inject_command("; mkdir #{path}; ")
    #       end
    #
    #     # ...
    #     obj.fs.mkdir('.temp')
    #
    # @since 1.0.0
    #
    module Mixin
      #
      # The controlled resources.
      #
      # @return [Hash{Symbol => Resource}]
      #   The controlled resources.
      #
      # @api semipublic
      #
      def resources
        @resources ||= Hash.new do |hash,key| 
          if (resource = Resources.require_const(key))
            hash[key] = resource.new(self)
          end
        end
      end

      #
      # The File-System resource.
      #
      # @return [Resources::FS]
      #   The File-System resource.
      #
      # @api public
      #
      def fs
        resources[:fs]
      end

      #
      # The Process resource.
      #
      # @return [Resources::Process]
      #   The Process resource.
      #
      # @api public
      #
      def process
        resources[:process]
      end

      #
      # The Shell resource.
      #
      # @return [Resources::Shell]
      #   The Shell resource.
      #
      # @api public
      #
      def shell
        resources[:shell]
      end

      #
      # Used to define post-exploitation methods.
      #
      # @yield []
      #   The given block will be evaluated within the object.
      #
      # @example
      #   post_exploitation do
      #     def fs_read(path,pos)
      #       # ...
      #     end
      #   end
      #   
      def post_exploitation(&block)
        instance_eval(&block)
      end
    end
  end
end