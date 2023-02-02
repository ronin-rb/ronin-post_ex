### 0.1.0 / 2023-02-01

* Initial release:
  * Defines a syscall-like [API for Post-Exploitation][API Spec].
  * Provides classes for interacting with the Post-Exploitation API.
    * {Ronin::PostEx::System} - allows interacting with a remote system.
    * {Ronin::PostEx::System::FS} - allows interacting with the file-system.
    * {Ronin::PostEx::System::Process} - allows manipulating the current process
      or child processes.
    * {Ronin::PostEx::System::Shell} - allows interacting with an interactive
      shell..
    * {Ronin::PostEx::RemoteFile} - allows reading/writing files.
    * {Ronin::PostEx::RemoteDir} - allows reading the contents of directories.
    * {Ronin::PostEx::RemoteProcess} - allows reading/writing to an running
      command.
  * Supports interacting with interactive shell commands.
  * Provides interactive command shells for interacting with systems.
  * Supports Linux/BSD/UNIX systems.
  * Provides common post-exploitation session classes for interacting with
    shells, bind shells, and reverse shells.
  * Supports defining custom post-exploitation session classes.

[API Spec]: https://github.com/ronin-rb/ronin-post_ex/blob/main/API_SPEC.md
