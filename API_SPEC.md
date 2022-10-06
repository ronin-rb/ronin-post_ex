# Post-Exploitation API Specification

## Sys Functions

### `sys_time -> Integer`

Gets the current time and returns the UNIX timestamp.

## File Functions

### `file_open(path : String, mode : String) -> Integer`

Opens a file and returns the file-descriptor number.

### `file_read(fd : Integer, length : Integer) -> String | nil`

Reads from an opened file-descriptor and returns the read data.
`nil` will be returned if there is no more data to be read.

### `file_write(fd : Integer, pos : Integer, data : String) -> Integer`

Writes data to the opened file-descriptor.

### `file_seek(fd : Integer, new_pos : Integer, whence : File::SEEK_SET | File::SEEK_CUR | File::SEEK_END | File::SEEK_DATA | File::SEEK_HOLE)`

Seeks to a position within the file.

### `file_tell(fd : Integer) -> Integer`

Queries the current position within the file.

### `file_ioctl(fd : Integer, command : String | Array[Integer], argument : Object) -> Integer`

Performs a `ioctl()` operation on the file-descriptor.

### `file_fcntl(fd : Integer, command : String | Array[Integer], argument : Object) -> Integer`

Performs a `fcntl()` operation on the file-descriptor.

### `file_stat(fd : Integer) => Hash[Symbol, Object] | nil`

Queries file information from the given file-descriptor and returns a Hash of
file metadata.

### `file_close(fd : Integer)`

Closes an opened file-descriptor.

## File-System Functions

### `fs_getcwd() -> String`

Gets the current working directory and returns the directory path.

### `fs_chdir(path : String)`

Changes the current working directory.

### `fs_readfile(path : String) -> String | nil`

Reads the entire file at the given path and returns the full file's contents.

### `fs_readlink(path : String) -> String`

Reads the destination path of a symbolic link.

### `fs_readdir(path : String) -> Array[String]`

Reads the contents of the directory and returns an Array of directory entry
names.

### `fs_glob(pattern : String) -> Array[String]`

Evaluates a directory glob pattern and returns all matching paths.

### `fs_mktemp(basename : String) -> String`

Creates a temporary file with the given file basename.

### `fs_mkdir(new_path : String)`

Creates a new directory at the given path.

### `fs_copy(src : String, dest : String)`

Copies a source file to the destination path.

### `fs_unlink(path : String)`

Removes a file at the given path.

### `fs_rmdir(path : String)`

Removes an empty directory at the given path.

### `fs_move(src : String, dest : String)`

Moves or renames a source file to a destination path.

### `fs_link(src : String, dest : String)`

Creates a symbolic link at the destination path pointing to the source path.

### `fs_chgrp(group : String, path : String)`

Changes the group ownership of a file or directory.

### `fs_chown(user : String, path : String)`

Changes the user ownership of a file or directory.

### `fs_chmod(mode : Integer, path : String)`

Changes the permissions on a file or directory.

### `fs_compare(file1 : String, file2 : String) -> Boolean`

Compares one file with another file and returns whether they are the same.

### `fs_stat(path : String) => Hash[Symbol, Object] | nil`

Queries file information from the given path and returns a Hash of file
metadata.

## Process Functions

### `process_getpid -> Integer`

Gets the current process's Process ID (PID).

### `process_getppid -> Integer`

Gets the current process's parent Process ID (PPID).

### `process_getuid -> Integer`

Gets the current process's user ID (UID).

### `process_setuid(uid : Integer)`

Sets the current process's user ID (UID) to the given Integer.

### `process_geteuid -> Integer`

Gets the current process's effective UID (EUID).

### `process_seteuid(euid : Integer)`

Sets the current process's effective UID (EUID) to the given Integer.

### `process_getgid -> Integer`

Gets the current process's group ID (GID).

### `process_setgid(gid : Integer)`

Sets the current process's group ID (GID) to the given Integer.

### `process_getegid -> Integer`

Gets the current process's effective group ID (EGID).

### `process_setegid(egid : Integer)`

Sets the current process's effective group ID (EGID) to the given Integer.

### `process_getsid -> Integer`

Gets the current process's session ID (SID).

### `process_setsid(sid : Integer) -> Integer`

Sets the current process's session ID (SID).

### `process_environ -> Hash[String, String]`

Queries all environment variables of the current process. Returns a Hash of the
env variable names and values.

### `process_getenv(name : String) -> String | nil`

Gets an individual environment variable. If the environment variable has not
been set, `nil` will be returned.

### `process_setenv(name : String, value : String)`

Sets an environment variable to the given value.

### `process_unsetenv(name : String)`

Un-sets an environment variable.

### `process_kill(pid : Integer, signal : Integer)`

Kills another process using the given Process ID (POD) and the signal number.

### `process_getcwd -> String`

Gets the process's current working directory.

### `process_chdir(path : String)`

Changes the process's current working directory.

### `process_spawn(program : String, *arguments : Array[String]) -> Integer`

Spawns a new process using the given program and additional arguments.
The process ID (PID) of the new process will be returned.

### `process_exit`

Exits the current process.

## Shell Functions

### `shell_exec(program : String, *arguments : Array[String]) { |data : String| ... }`

Executes a new shell command using the given program name and additional
arguments. The method will then yield the data outputted by the shell command.

### `shell_write(data : String)`

Writes the given data to the shell.

