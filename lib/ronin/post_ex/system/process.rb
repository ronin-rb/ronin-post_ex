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

require 'ronin/post_ex/resource'

require 'time'

module Ronin
  module PostEx
    class System < Resource
      #
      # Provides access to the current process and managing child processes.
      #
      # # Supported Control Methods
      #
      # The Process resource uses the following API methods, defined by the
      # API object.
      #
      # * `process_getpid -> Integer`
      # * `process_getppid -> Integer`
      # * `process_getuid -> Integer`
      # * `process_setuid(uid : Integer)`
      # * `process_geteuid -> Integer`
      # * `process_seteuid(euid : Integer)`
      # * `process_getgid -> Integer`
      # * `process_setgid(gid : Integer)`
      # * `process_getegid -> Integer`
      # * `process_setegid(egid : Integer)`
      # * `process_getsid -> Integer`
      # * `process_setsid(sid : Integer) -> Integer`
      # * `process_environ -> Hash[String, String]`
      # * `process_getenv(name : String) -> String | env`
      # * `process_setenv(name : String, value : String)`
      # * `process_unsetenv(name : String)`
      # * `process_kill(pid : Integer, signal : Integer)`
      # * `process_getcwd -> String`
      # * `process_chdir(path : String)`
      # * `process_spawn(program : String, *arguments : Array[String]) -> Integer`
      # * `process_exit`
      #
      class Process < Resource

        #
        # Gets the pid of the current process.
        #
        # @return [Integer]
        #   The current PID.
        #
        # @note
        #   Requires the `process_getpid` method be defined by the API object.
        #
        def getpid
          @api.process_getpid
        end
        resource_method :pid, [:process_getpid]

        alias pid getpid

        #
        # Gets the pid of the parent process.
        #
        # @return [Integer]
        #   The parent PID.
        #
        # @note
        #   Requires the `process_getppid` method be defined by the API object.
        #
        def getppid
          @api.process_getppid
        end
        resource_method :ppid, [:process_getppid]

        alias ppid getppid

        #
        # Gets the UID that the current process is running under.
        #
        # @return [Integer]
        #   The current UID.
        #
        # @note
        #   Requires the `process_getuid` method be defined by the API object.
        #
        def getuid
          @api.process_getuid
        end
        resource_method :uid, [:process_getuid]

        alias uid getuid

        #
        # Attempts to set the UID of the current process.
        #
        # @param [Integer] new_uid
        #   The new UID.
        #
        # @note
        #   Requires the `process_setuid` method be defined by the API object.
        #
        def setuid(new_uid)
          @api.process_setuid(new_uid)
        end
        resource_method :uid=, [:process_setuid]

        alias uid= setuid

        #
        # Gets the effective UID that the current process is running under.
        #
        # @return [Integer]
        #   The effective UID.
        #
        # @note
        #   Requires the `process_geteuid` method be defined by the API object.
        #
        def geteuid
          @api.process_geteuid
        end
        resource_method :euid, [:process_geteuid]

        alias euid geteuid

        #
        # Attempts to set the effective UID of the current process.
        #
        # @param [Integer] new_euid
        #   The new effective UID.
        #
        # @note
        #   Requires the `process_seteuid` method be defined by the API object.
        #
        def seteuid(new_euid)
          @api.process_seteuid(new_euid)
        end
        resource_method :euid=, [:process_seteuid]

        alias euid= seteuid

        #
        # Gets the GID that the current process is running under.
        #
        # @return [Integer]
        #   The current GID.
        #
        # @note
        #   Requires the `process_getgid` method be defined by the API object.
        #
        def getgid
          @api.process_getgid
        end
        resource_method :gid, [:process_getgid]

        alias gid getgid

        #
        # Attempts to set the GID of the current process.
        #
        # @param [Integer] new_gid
        #   The new GID.
        #
        # @note
        #   Requires the `process_setgid` method be defined by the API object.
        #
        def setgid(new_gid)
          @api.process_setgid(new_gid)
        end
        resource_method :gid=, [:process_setgid]

        alias gid= setgid

        #
        # Gets the effective GID that the current process is running under.
        #
        # @return [Integer]
        #   The effective GID.
        #
        # @note
        #   Requires the `process_getegid` method be defined by the API object.
        #
        def getegid
          @api.process_getegid
        end
        resource_method :egid, [:process_getegid]

        alias egid getegid

        #
        # Attempts to set the effective GID of the current process.
        #
        # @param [Integer] new_egid
        #   The new effective GID.
        #
        # @note
        #   Requires the `process_setegid` method be defined by the API object.
        #
        def setegid(new_egid)
          @api.process_setegid(new_egid)
        end
        resource_method :egid=, [:process_setegid]

        alias egid= setegid

        #
        # Gets the SID of the current process.
        #
        # @return [Integer]
        #   The current SID.
        #
        # @note
        #   Requires the `process_getsid` method be defined by the API object.
        #
        def getsid
          @api.process_getsid
        end
        resource_method :sid, [:process_getsid]

        alias sid getsid

        #
        # Sets the SID of the current process.
        #
        # @note
        #   Requires the `process_setsid` method be defined by the API object.
        #
        def setsid
          @api.process_setsid
        end
        resource_method :setsid, [:process_setsid]

        alias sid! setsid

        #
        # Retrieves the whole environment Hash.
        #
        # @return [Hash{String => String}]
        #   The Hash of environment variables.
        #
        # @note
        #   Requires the `process_environ` method be defined by the API object.
        #
        # @api public
        #
        def environ
          @api.process_environ
        end
        resource_method :environ, [:process_environ]

        alias env environ

        #
        # Retrieves the value of a environment variable.
        #
        # @param [String] name
        #   The name of the environment variable.
        #
        # @return [String, nil]
        #   The value of the environment variable.
        #
        # @note
        #   Requires `process_getenv` or `process_environ` methods be defined by
        #   the API object.
        #
        # @api public
        #
        def getenv(name)
          if @api.respond_to?(:process_getenv)
            @api.process_getenv(name)
          elsif @api.respond_to?(:process_environ)
            @api.process_environ[name]
          else
            raise(NoMethodError,"#{@api} does not define process_getenv or process_environ")
          end
        end
        resource_method :getenv, [:process_getenv]

        #
        # Sets the value of a environment variable.
        #
        # @param [String] name
        #   The name of the environment variable.
        #
        # @param [String] value
        #   The new value for the environment variable.
        #
        # @note
        #   Requires the `process_setenv` method be defined by the API object.
        #
        # @api public
        #
        def setenv(name,value)
          @api.process_setenv(name,value)
        end
        resource_method :setenv, [:process_setenv]

        #
        # Unsets an environment variable.
        #
        # @param [String] name
        #   The name of the environment variable.
        #
        # @note
        #   Requires the `process_unsetenv` method be defined by the API object.
        #
        # @api public
        #
        def unsetenv(name)
          @api.process_unsetenv(name)
        end
        resource_method :unsetenv, [:process_unsetenv]

        #
        # Kills a process.
        #
        # @param [Integer] pid
        #   The PID of the process to kill.
        #
        # @param [String] signal
        #   The POSIX signal name to send to the process.
        #
        # @note
        #   Requires the `process_kill` method be defined by the API object.
        #
        def kill(pid,signal='KILL')
          @api.process_kill(pid,signal)
        end
        resource_method :kill, [:process_kill]

        #
        # Gets the working directory of the current process.
        #
        # @return [String]
        #   The current working directory.
        #
        # @note
        #   Requires the `process_getcwd` method be defined by the API object.
        #
        def getcwd
          @api.process_getcwd
        end
        resource_method :getcwd, [:process_getcwd]

        alias cwd getcwd

        #
        # Changes the working directory of the current process.
        #
        # @param [String] path
        #   The new working directory.
        #
        # @return [String]
        #   The new current working directory.
        #
        # @note
        #   Requires the `process_chdir` method be defined by the API object.
        #
        def chdir(path)
          @api.process_chdir(path)
        end
        resource_method :chdir, [:process_chdir]

        alias cwd= chdir

        #
        # Executes a program as a separate child process.
        #
        # @param [String] program
        #   The name or path of the program.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to execute the program with.
        #
        # @return [Integer]
        #   The pid of the new process.
        #
        # @note
        #   Requires the `process_spawn` method be defined by the API object.
        #
        # @api public
        #
        def spawn(program,*arguments)
          @api.process_spawn(program,*arguments)
        end
        resource_method :spawn, [:process_spawn]

        #
        # Exits the current running process.
        #
        # @note
        #   Requires the `process_exit` method be defined by the API object.
        #
        def exit
          @api.process_exit
        end
        resource_method :exit, [:process_exit]

      end
    end
  end
end
