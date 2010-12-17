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

require 'ronin/leverage/resources/resource'

module Ronin
  module Leverage
    module Resources
      #
      # Leverages other System resources.
      #
      class Sys < Resource

        #
        # Gets the pid of the current process.
        #
        # @return [Integer]
        #   The current PID.
        #
        # @note
        #   Requires the `sys_getpid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def pid
          requires_method! :sys_getpid

          @leverage.sys_getpid
        end

        #
        # Gets the pid of the parent process.
        #
        # @return [Integer]
        #   The parent PID.
        #
        # @note
        #   Requires the `sys_getppid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def ppid
          requires_method! :sys_getppid

          @leverage.sys_getppid
        end

        #
        # Gets the UID that the current process is running under.
        #
        # @return [Integer]
        #   The current UID.
        #
        # @note
        #   Requires the `sys_getuid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def uid
          requires_method! :sys_getuid

          @leverage.sys_getuid
        end

        #
        # Attempts to set the UID of the current process.
        #
        # @param [Integer] new_uid
        #   The new UID.
        #
        # @note
        #   Requires the `sys_setuid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def uid=(new_uid)
          requires_method! :sys_setuid

          @leverage.sys_setuid(new_uid)
        end

        #
        # Gets the effective UID that the current process is running under.
        #
        # @return [Integer]
        #   The effective UID.
        #
        # @note
        #   Requires the `sys_geteuid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def euid
          requires_method! :sys_geteuid

          @leverage.sys_geteuid
        end

        #
        # Attempts to set the effective UID of the current process.
        #
        # @param [Integer] new_euid
        #   The new effective UID.
        #
        # @note
        #   Requires the `sys_seteuid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def euid=(new_euid)
          requires_method! :sys_seteuid

          @leverage.sys_seteuid(new_euid)
        end

        #
        # Gets the GID that the current process is running under.
        #
        # @return [Integer]
        #   The current GID.
        #
        # @note
        #   Requires the `sys_getgid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def gid
          requires_method! :sys_getgid

          @leverage.sys_getgid
        end

        #
        # Attempts to set the GID of the current process.
        #
        # @param [Integer] new_gid
        #   The new GID.
        #
        # @note
        #   Requires the `sys_setgid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def gid=(gid)
          requires_method! :sys_setgid

          @leverage.sys_setgid(new_gid)
        end

        #
        # Gets the effective GID that the current process is running under.
        #
        # @return [Integer]
        #   The effective GID.
        #
        # @note
        #   Requires the `sys_getegid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def egid
          requires_method! :sys_getegid

          @leverage.sys_getegid
        end

        #
        # Attempts to set the effective GID of the current process.
        #
        # @param [Integer] new_egid
        #   The new effective GID.
        #
        # @note
        #   Requires the `sys_setegid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def egid=(new_egid)
          requires_method! :sys_setegid

          @leverage.sys_setegid(new_egid)
        end

        #
        # Gets the SID of the current process.
        #
        # @return [Integer]
        #   The current SID.
        #
        # @note
        #   Requires the `sys_getsid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def sid
          requires_method! :sys_getsid

          @leverage.sys_getsid
        end

        #
        # Sets the SID of the current process.
        #
        # @param [Integer] new_sid
        #   The new SID.
        #
        # @note
        #   Requires the `sys_setsid` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def setsid(new_sid)
          requires_method! :sys_setsid

          @leverage.sys_setsid(new_sid)
        end

        #
        # Kills a process.
        #
        # @param [Integer] pid
        #   The PID of the process to kill.
        #
        # @note
        #   Requires the `sys_kill` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def kill(pid)
          requires_method! :sys_kill

          @leverage.sys_kill(pid)
        end

        #
        # Gets the working directory of the current process.
        #
        # @return [String]
        #   The current working directory.
        #
        # @note
        #   Requires the `sys_getcwd` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def getcwd
          requires_method! :sys_getcwd

          @leverage.sys_getcwd
        end

        #
        # Changes the working directory of the current process.
        #
        # @param [String] path
        #   The new working directory.
        #
        # @note
        #   Requires the `sys_chdir` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def chdir(path)
          requires_method! :sys_chdir

          @leverage.sys_chdir(path)
        end

        #
        # Gets the current time.
        #
        # @return [Time]
        #   The current time.
        #
        # @note
        #   Requires the `sys_time` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def time
          requires_method! :sys_time

          @leverage.sys_time
        end

        #
        # Exits the current running process.
        #
        # @note
        #   Requires the `sys_exit` method be defined by the leveraging
        #   object.
        #
        # @since 0.4.0
        #
        def exit
          requires_method! :sys_exit

          @leverage.sys_exit
        end

      end
    end
  end
end
