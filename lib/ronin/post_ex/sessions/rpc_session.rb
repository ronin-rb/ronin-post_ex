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

require 'ronin/post_ex/sessions/session'

module Ronin
  module PostEx
    module Sessions
      #
      # Provides a post-exploitation session which wraps around an RPC client.
      #
      class RPCSession < Session

        # The RPC client object.
        #
        # @return [#call]
        #
        # @api private
        attr_reader :client

        #
        # Initializes the RPC session.
        #
        # @param [#call] client
        #   The RPC client. It must define a `call` method.
        #
        def initialize(client)
          @client = client
        end

        #
        # Calls the RPC method.
        #
        # @param [String] method
        #   The RPC method name to call.
        #
        # @param [Array] arguments
        #   Additional arguments for the RPC method.
        #
        # @return [Object]
        #   The result value from the RPC method.
        #
        def call(method,*arguments)
          @client.call(method,*arguments)
        end

        #
        # @group System Methods
        #

        #
        # Gets the current time and returns the UNIX timestamp.
        #
        # @return [Integer]
        #   The current time as a UNIX timestamp.
        #
        # @note calls the `sys.time` RPC function.
        #
        def sys_time
          call('sys.time')
        end

        #
        # Gets the system's hostname.
        #
        # @return [String]
        #
        # @note calls the `sys.hostname` RPC function.
        #
        def sys_hostname
          call('sys.hostname')
        end

        #
        # @group File Methods
        #

        #
        # Opens a file and returns the file-descriptor number.
        #
        # @param [String] path
        #   The remote file path to open.
        #
        # @param [String] mode
        #   The mode to open the file.
        #
        # @return [Integer]
        #   The opened remote file descriptor.
        #
        # @note calls the `file.open` RPC function.
        #
        def file_open(path,mode='r')
          call('file.open',path,mode)
        end

        #
        # Reads from an opened file-descriptor and returns the read data.
        #
        # @param [Integer] fd
        #   The remote file descriptor to read from.
        #
        # @param [Integer] length
        #   The length of data in bytes to read from the file descriptor.
        #
        # @return [String, nil]
        #   Returns the read data or `nil` if there is no more data to be read.
        #
        # @note calls the `file.read` RPC function.
        #
        def file_read(fd,length)
          call('file.read',fd,length)
        end

        #
        # Writes data to the opened file-descriptor.
        #
        # @param [Integer] fd
        #   The remote file descriptor to write to.
        #
        # @param [Integer] pos
        #   The position to write the data at.
        #
        # @param [String] data
        #   The data to write.
        #
        # @return [Integer]
        # 
        # @note calls the `file.write` RPC function.
        #
        def file_write(fd,pos,data)
          call('file.write',fd,pos,data)
        end

        #
        # Seeks to a position within the file.
        #
        # @param [Integer] fd
        #   The remote file descriptor to seek.
        #
        # @param [Integer] new_pos
        #   The new position to seek to.
        #
        # @param [String] whence
        #   How the position should be interpreted. Must be one of the
        #   following String values:
        #   * `"SEEK_SET"` - seek from beginning of file.
        #   * `"SEEK_CUR"` - seek from current position.
        #   * `"SEEK_END"` - seek from end of file.
        #   * `"SEEK_DATA"` - seek to next data.
        #   * `"SEEK_HOLE"` - seek to next hole.
        #
        # @note calls the `file.seek` RPC function.
        #
        def file_seek(fd,new_pos,whence)
          call('file.seek',fd,new_pos,whence)
        end

        #
        # Queries the current position within the file.
        #
        # @param [Integer] fd
        #   The remote file descriptor to query.
        #
        # @return [Integer]
        #   The current position of the remote file descriptor.
        #
        # @note calls the `file.tell` RPC function.
        #
        def file_tell(fd)
          call('file.tell',fd)
        end

        #
        # Performs a `ioctl()` operation on the file-descriptor.
        #
        # @param [Integer] fd
        #   The remote file descriptor to perform the `ioctl()` on.
        #
        # @param [String, Array<Integer>] command
        #   The `ioctl()` command String or Array of bytes.
        #
        # @param [Object] argument
        #   The additional `ioctl()` argument.
        #
        # @return [Integer]
        #   The return value of the `ioctl()`.
        #
        # @note calls the `file.ioctl` RPC function.
        #
        def file_ioctl(fd,command,argument)
          call('file.ioctl',fd,command,argument)
        end

        #
        # Performs a `fcntl()` operation on the file-descriptor.
        #
        # @param [Integer] fd
        #   The remote file descriptor to perform the `fcntl()` on.
        #
        # @param [String, Array<Integer>] command
        #   The `fcntl()` command String or Array of bytes.
        #
        # @param [Object] argument
        #   The additional `fcntl()` argument.
        #
        # @return [Integer]
        #   The return value of the `fcntl()`.
        #
        # @note calls the `file.fcntl` RPC function.
        #
        def file_fcntl(fd,command,argument)
          call('file.fcntl',fd,command,argument)
        end

        #
        # Queries file information from the given file-descriptor and returns a
        # Hash of file metadata.
        #
        # @param [Integer] fd
        #   The remote file descriptor to query.
        #
        # @return [Hash{Symbol => Object}, nil]
        #   The Hash of file metadata or `nil` if the remote file descriptor
        #   could not be stat-ed.
        #
        # @note calls the `file.stat` RPC function.
        #
        def file_stat(fd)
          call('file.stat',fd)
        end

        #
        # Closes an opened remote file-descriptor.
        #
        # @param [Integer] fd
        #   The remote file descriptor to close.
        #
        # @note calls the `file.close` RPC function.
        #
        def file_close(fd)
          call('file.close',fd)
        end

        #
        # @group File-System methods
        #

        #
        # Gets the current working directory and returns the directory path.
        #
        # @return [String]
        #   The remote current working directory.
        #
        # @note calls the `fs.getcwd` RPC function.
        #
        def fs_getcwd
          call('fs.getcwd')
        end

        #
        # Changes the current working directory.
        #
        # @param [String] path
        #   The new remote current working directory.
        #
        # @note calls the `fs.chdir` RPC function.
        #
        def fs_chdir(path)
          call('fs.chdir',path)
        end

        #
        # Reads the entire file at the given path and returns the full file's
        # contents.
        #
        # @param [String] path
        #   The remote path to read.
        #
        # @return [String, nil]
        #   The contents of the remote file or `nil` if the file could not be
        #   read.
        #
        # @note calls the `fs.readfile` RPC function.
        #
        def fs_readfile(path)
          call('fs.readfile',path)
        end

        #
        # Reads the destination path of a remote symbolic link.
        #
        # @param [String] path
        #   The remote path to read.
        #
        # @return [String, nil]
        #   The destination of the remote symbolic link or `nil` if the symbolic
        #   link could not be read.
        #
        # @note calls the `fs.readlink` RPC function.
        #
        def fs_readlink(path)
          call('fs.readlink',path)
        end

        #
        # Reads the contents of a remote directory and returns an Array of
        # directory entry names.
        #
        # @param [String] path
        #   The path of the remote directory to read.
        #
        # @return [Array<String>]
        #   The entities within the remote directory.
        #
        # @note calls the `fs.readdir` RPC function.
        #
        def fs_readdir(path)
          call('fs.readdir',path)
        end

        #
        # Evaluates a directory glob pattern and returns all matching paths.
        #
        # @param [String] pattern
        #   The glob pattern to search for remotely.
        #
        # @return [Array<String>]
        #   The matching paths.
        #
        # @note calls the `fs.glob` RPC function.
        #
        def fs_glob(pattern)
          call('fs.glob',pattern)
        end

        #
        # Creates a remote temporary file with the given file basename.
        #
        # @param [String] basename
        #   The basename for the new temporary file.
        #
        # @return [String]
        #   The path of the newly created temporary file.
        #
        # @note calls the `fs.mktemp` RPC function.
        #
        def fs_mktemp(basename)
          call('fs.mktemp',basename)
        end

        #
        # Creates a new remote directory at the given path.
        #
        # @param [String] new_path
        #   The new remote directory to create.
        #
        # @note calls the `fs.mkdir` RPC function.
        #
        def fs_mkdir(new_path)
          call('fs.mkdir',new_path)
        end

        #
        # Copies a source file to the destination path.
        #
        # @param [String] src
        #   The source file.
        #
        # @param [String] dest
        #   The destination path.
        #
        # @note calls the `fs.copy` RPC function.
        #
        def fs_copy(src,dest)
          call('fs.copy',src,dest)
        end

        #
        # Removes a file at the given path.
        #
        # @param [String] path
        #   The remote path to remove.
        #
        # @note calls the `fs.unlink` RPC function.
        #
        def fs_unlink(path)
          call('fs.unlink',path)
        end

        #
        # Removes an empty directory at the given path.
        #
        # @param [String] path
        #   The remote directory path to remove.
        #
        # @note calls the `fs.rmdir` RPC function.
        #
        def fs_rmdir(path)
          call('fs.rmdir',path)
        end

        #
        # Moves or renames a remote source file to a new destination path.
        #
        # @param [String] src
        #   The source file path.
        #
        # @param [String] dest
        #   The destination file path.
        #
        # @note calls the `fs.move` RPC function.
        #
        def fs_move(src,dest)
          call('fs.move',src,dest)
        end

        #
        # Creates a remote symbolic link at the destination path pointing to the
        # source path.
        #
        # @param [String] src
        #   The source file path for the new symbolic link.
        #
        # @param [String] dest
        #   The remote path of the new symbolic link.
        #
        # @note calls the `fs.link` RPC function.
        #
        def fs_link(src,dest)
          call('fs.link',src,dest)
        end

        #
        # Changes the group ownership of a remote file or directory.
        #
        # @param [String] group
        #   The new group name for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note calls the `fs.chgrp` RPC function.
        #
        def fs_chgrp(group,path)
          call('fs.chgrp',group,path)
        end

        #
        # Changes the user ownership of remote a file or directory.
        #
        # @param [String] user
        #   The new user for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note calls the `fs.chown` RPC function.
        #
        def fs_chown(user,path)
          call('fs.chown',user,path)
        end

        #
        # Changes the permissions on a remote file or directory.
        #
        # @param [Integer] mode
        #   The permissions mode for the remote file or directory.
        #
        # @param [String] path
        #   The path of the remote file or directory.
        #
        # @note calls the `fs.chmod` RPC function.
        #
        def fs_chmod(mode,path)
          call('fs.chmod',mode,path)
        end

        #
        # Queries file information for the given remote path and returns a Hash
        # of file metadata.
        #
        # @param [String] path
        #   The path to the remote file or directory.
        #
        # @return [Hash{Symbol => Object}, nil]
        #   The metadata for the remote file.
        #
        # @note calls the `fs.stat` RPC function.
        #
        def fs_stat(path)
          call('fs.stat',path)
        end

        #
        # @group Process methods
        #

        #
        # Gets the current process's Process ID (PID).
        #
        # @return [Integer]
        #   The current process's PID.
        #
        # @note calls the `process.getpid` RPC function.
        #
        def process_getpid
          call('process.getpid')
        end

        #
        # Gets the current process's parent Process ID (PPID).
        #
        # @return [Integer]
        #   The current process's PPID.
        #
        # @note calls the `process.getppid` RPC function.
        #
        def process_getppid
          call('process.getppid')
        end

        #
        # Gets the current process's user ID (UID).
        #
        # @return [Integer]
        #   The current process's UID.
        #
        # @note calls the `process.getuid` RPC function.
        #
        def process_getuid
          call('process.getuid')
        end

        #
        # Sets the current process's user ID (UID) to the given Integer.
        #
        # @param [Integer] uid
        #   The new UID for the current process.
        #
        # @note calls the `process.setuid` RPC function.
        #
        def process_setuid(uid)
          call('process.setuid',uid)
        end

        #
        # Gets the current process's effective UID (EUID).
        #
        # @return [Integer]
        #   the effective UID (EUID) for the current process.
        #
        # @note calls the `process.geteuid` RPC function.
        #
        def process_geteuid
          call('process.geteuid')
        end

        #
        # Sets the current process's effective UID (EUID) to the given Integer.
        #
        # @param [Integer] euid
        #   The new effective UID (EUID) for the current process.
        #
        # @note calls the `process_seteuid` RPC function.
        #
        def process_seteuid(euid)
          call('process.seteuid',euid)
        end

        #
        # Gets the current process's group ID (GID).
        #
        # @return [Integer]
        #   The group ID (GID) for the current process.
        #
        # @note calls the `process_getgid` RPC function.
        #
        def process_getgid
          call('process.getgid')
        end

        #
        # Sets the current process's group ID (GID) to the given Integer.
        #
        # @param [Integer] gid
        #   The new group ID (GID) for the current process.
        #
        # @note calls the `process_setgid` RPC function.
        #
        def process_setgid(gid)
          call('process.setgid',gid)
        end

        #
        # Gets the current process's effective group ID (EGID).
        #
        # @return [Integer]
        #   The effective group ID (EGID) of the current process.
        #
        # @note calls the `process_getegid` RPC function.
        #
        def process_getegid
          call('process.getegid')
        end

        #
        # Sets the current process's effective group ID (EGID) to the given
        # Integer.
        #
        # @param [Integer] egid
        #   The new effective group ID (EGID) for the current process.
        #
        # @note calls the `process_setegid` RPC function.
        #
        def process_setegid(egid)
          call('process.setegid',egid)
        end

        #
        # Gets the current process's session ID (SID).
        #
        # @return [Integer]
        #   the session ID (SID) of the current process.
        #
        # @note calls the `process.getsid` RPC function.
        #
        def process_getsid
          call('process.getsid')
        end

        #
        # Sets the current process's session ID (SID).
        #
        # @param [Integer] sid
        #   The new session ID (SID) for the current process.
        #
        # @note calls the `process.setsid` RPC function.
        #
        def process_setsid(sid)
          call('process.setsid',sid)
        end

        #
        # Queries all environment variables of the current process. Returns a
        # Hash of the env variable names and values.
        #
        # @return [Hash{String => String}]
        #   The Hash of environment variables.
        #
        # @note calls the `process.environ` RPC function.
        #
        def process_environ
          call('process.environ')
        end

        #
        # Gets an individual environment variable. If the environment variable
        # has not been set, `nil` will be returned.
        #
        # @param [String] name
        #   The environment variable name to get.
        #
        # @return [String, nil]
        #   The environment variable value.
        #
        # @note calls the `process.getenv` RPC function.
        #
        def process_getenv(name)
          call('process.getenv',name)
        end

        #
        # Sets an environment variable to the given value.
        #
        # @param [String] name
        #   The environment variable name to set.
        #
        # @param [String] value
        #   The new value for the environment variable.
        #
        # @note calls the `process.setenv` RPC function.
        #
        def process_setenv(name,value)
          call('process.setenv',name,value)
        end

        #
        # Un-sets an environment variable.
        #
        # @param [String] name
        #   The environment variable to unset.
        #
        # @note calls the `process.unsetenv` RPC function.
        # 
        def process_unsetenv(name)
          call('process.unsetenv',name)
        end

        #
        # Kills another process using the given Process ID (POD) and the signal
        # number.
        #
        # @param [Integer] pid
        #   The process ID (PID) to kill.
        #
        # @param [Integer] signal
        #   The signal to send the process ID (PID).
        #
        # @note calls the `process.kill` RPC function.
        #
        def process_kill(pid,signal)
          call('process.kill',pid,signal)
        end

        #
        # Spawns a new process using the given program and additional arguments.
        #
        # @param [String] program
        #   The program name to spawn.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the program.
        #
        # @return [Integer]
        #   The process ID (PID) of the spawned process.
        #
        # @note calls the `process.spawn` RPC function.
        #
        def process_spawn(program,*arguments)
          call('process.spawn',program,*arguments)
        end

        #
        # Exits the current process.
        #
        # @note calls the `process.exit` RPC function.
        #
        def process_exit
          call('process.exit')
        end

        #
        # @group Shell Methods
        #

        #
        # Executes a new shell command using the given program name and
        # additional arguments.
        #
        # @param [String] command
        #   The command to execute.
        #
        # @note calls the `shell.exec` RPC function.
        #
        def shell_exec(command)
          call('shell.exec',command)
        end

      end
    end
  end
end
