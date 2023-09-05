# ronin-post_ex

[![CI](https://github.com/ronin-rb/ronin-post_ex/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-post_ex/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-post_ex.svg)](https://codeclimate.com/github/ronin-rb/ronin-post_ex)
[![Gem Version](https://badge.fury.io/rb/ronin-post_ex.svg)](https://badge.fury.io/rb/ronin-post_ex)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-post_ex)
* [Issues](https://github.com/ronin-rb/ronin-post_ex/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-post_ex/frames)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-post_ex is a Ruby API for Post-Exploitation.

This library is used by [ronin-payloads], [ronin-c2], and [ronin-exploits]
to provide a Post-Exploitation API around payloads, C2 sessions, or even
exploits.

ronin-post_ex is part of the [ronin-rb] project, a [Ruby] toolkit for security
research and development.

## Features

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
* Provides common post-exploitation session classes for interacting with shells,
  bind shells, and reverse shells.
* Supports defining custom post-exploitation session classes.

## Limitations

* Does not currently support Windows systems.
* Does not fully support bidirectional fully interactive shell commands.

## Examples

### Bind Shell

```ruby
session = Ronin::PostEx::Sessions::BindShell.connect(host,port)
system  = session.system

system.shell.ls('/')
# => "..."
```

### Reverse Shell

```ruby
session = Ronin::PostEx::Sessions::ReverseShell.listen(host,port)
system  = session.system

system.shell.ls('/')
# => "..."
```

### Custom Session Class

Define a custom session class which defines the
[Post-Exploitation API methods][API Spec]:

```ruby
class RATSession < Ronin::PostEx::Sessions::Session

  def initialize(host,port)
    # ...
  end

  def rpc_call(method,*arguments)
    # ...
  end

  def fs_read(path)
    rpc_call("fs_read",path)
  end

  def shell_exec(command)
    rpc_call("shell_exec",command)
  end

  # ...

end

session = RATSession.new
system  = session.system
```

### System

Interact with the system's remote files as if they were local files:

```ruby
file = system.fs.open('/etc/passwd')

file.each_line do |line|
  user, x, uid, gid, name, home_dir, shell = line.split(':')

  puts "User Detected: #{user} (id=#{uid})"
end
```

Get information about the current process:

```ruby
system.process.pid
# => 1234

system.process.getuid
# => 1001

system.process.environ
# => {"HOME"=>"...", "PATH"=>"...", ...}
```

Execute commands on the remote system:

```ruby
system.shell.ls('/')
# => "bin\nboot\ndev\netc\nhome\nlib\nlib64\nlost+found\nmedia\nmnt\nopt\nproc\nroot\nrun\nsbin\nsnap\nsrv\nsys\ntmp\nusr\nvar\n"

system.shell.exec("find -type f -name '*.xls' /srv") do |path|
  puts "Found XLS file: #{path}"
end
```

Spawn an interactive command shell:

```ruby
system.shell.interact
$
```

Spawn an interactive post-exploitation system shell:

```ruby
system.interact
```
```
ronin-post_ex> help
  help [COMMAND]                	Prints the list of commands or additional help
  fs.chdir DIR                  	Changes the current working directory
  fs.pwd                        	Prints the current working directory
  fs.readfile FILE              	Reads the contents of a given FILE
  fs.readlink SYMLINK           	Reads the destination path of a symlink
  fs.readdir DIR                	Reads the contents of a given directory
  fs.hexdump FILE               	Hexdumps a given file
  fs.copy SRC DEST              	Copies the SRC file to the DEST path
  fs.unlink FILE                	Deletes a given file
  fs.rmdir DIR                  	Removes a given directory
  fs.mv SRC DEST                	Moves or renames a given file or directory
  fs.link SRC DEST              	Creates a link from the source to the destination
  fs.chown USER PATH            	Changes the owner of a given file or directory
  fs.chgrp GROUP PATH           	Changes the group of a given file or directory
  fs.chmod MODE PATH            	Changes the permission mode of a given file or directory
  fs.stat PATH                  	Prints file system information about a given file or directory
  fs.open PATH [MODE]           	Opens a file for reading or writing
  files                         	Lists opened files
  file.seek FILE_ID POS [WHENCE]	Seeks to a position within the file
  file.read FILE_ID LENGTH      	Reads LENGTH of data from an opened file
  file.write FILE_ID DATA       	Writes data to an opened file
  file.close FILE_ID            	Closes an open file
ronin-post_ex> 
```

## Requirements

* [Ruby] >= 3.0.0
* [fake_io] ~> 0.1
* [hexdump] ~> 1.0
* [ronin-core] ~> 0.1

## Install

```shell
$ gem install ronin-post_ex
```

### Gemfile

```ruby
gem 'ronin-post_ex', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-post_ex', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-post_ex/fork)
2. Clone It!
3. `cd ronin-post_ex/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2007-2023 Hal Brodigan (postmodern.mod3 at gmail.com)

ronin-post_ex is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-post_ex is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-post_ex.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[ronin-rb]: https://ronin-rb.dev

[fake_io]: https://github.com/postmodern/fake_io.rb#readme
[hexdump]: https://github.com/postmodern/hexdump.rb#readme
[ronin-core]: https://github.com/ronin-rb/ronin-core#readme
[ronin-payloads]: https://github.com/ronin-rb/ronin-payloads#readme
[ronin-c2]: https://github.com/ronin-rb/ronin-c2#readme
[ronin-exploits]: https://github.com/ronin-rb/ronin-exploits#readme

[API Spec]: https://github.com/ronin-rb/ronin-post_ex/blob/main/API_SPEC.md
