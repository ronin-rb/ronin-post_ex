require 'spec_helper'
require 'ronin/post_ex/sessions/shell_session'

require 'socket'

describe Ronin::PostEx::Sessions::ShellSession do
  let(:pipe)  { UNIXSocket.pair }
  let(:io)    { pipe[0] }
  let(:shell) { pipe[1] }

  subject { described_class.new(io) }

  describe "#initialize" do
    it "must set #io" do
      expect(subject.io).to be(io)
    end
  end

  describe "#shell_gets" do
    it "must read a line of text from #io" do
      thread = Thread.new do
        sleep 0.1
        shell.write("foo bar\n")
      end

      expect(subject.shell_gets).to eq("foo bar\n")
    end
  end

  describe "#shell_puts" do
    let(:line) { "foo bar" }

    it "must write a line of text to #io" do
      subject.shell_puts(line)

      expect(shell.gets).to eq("#{line}\n")
    end
  end

  describe "#shell_exec" do
    let(:command) { 'ls' }
    let(:output) do
      [
        "API_SPEC.md",
        "ChangeLog.md",
        "COPYING.txt",
        "Gemfile",
        "Gemfile.lock",
        "gemspec.yml",
        "lib",
        "Rakefile",
        "README.md",
        "ronin-post_ex.gemspec",
        "spec",
        "vendor"
      ].map { |line| "#{line}\n" }.join
    end

    it "must print a beginning deliminator, pipe the command into base64, and print an ending deliminator" do
      thread = Thread.new do
        sleep 0.1
        subject.shell_exec(command)
      end

      expect(shell.gets).to eq("echo #{described_class::DELIMINATOR}; #{command} 2>/dev/null | base64; echo #{described_class::DELIMINATOR}\n")
      shell.puts(described_class::DELIMINATOR)
      shell.write(Base64.encode64(output))
      shell.puts(described_class::DELIMINATOR)
    end

    it "must return the output of the command" do
      thread = Thread.new do
        sleep 0.1

        shell.gets
        shell.puts(described_class::DELIMINATOR)
        shell.write(Base64.encode64(output))
        shell.puts(described_class::DELIMINATOR)
      end

      expect(subject.shell_exec(command)).to eq(output)
    end
  end

  describe "#sys_time" do
    let(:timestamp) { 1668692783         }
    let(:output)    { "#{timestamp}\n"   }

    it "must run the 'date +%s' and parse the output as an Integer" do
      expect(subject).to receive(:shell_exec).with('date +%s').and_return(output)

      expect(subject.sys_time).to eq(timestamp)
    end
  end

  describe "#fs_getcwd" do
    let(:pwd)    { '/current/directory' }
    let(:output) { "#{pwd}\n" }

    it "must run the 'pwd' command and return the path" do
      expect(subject).to receive(:shell_exec).with('pwd').and_return(output)

      expect(subject.fs_getcwd).to eq(pwd)
    end
  end

  describe "#fs_chdir" do
    let(:new_dir) { '/path/to/directory' }
    let(:output)  { "\n" }

    it "must run the 'cd <path> 2>/dev/null' command" do
      expect(subject).to receive(:shell_puts).with("cd #{new_dir} 2>/dev/null")

      subject.fs_chdir(new_dir)
    end
  end

  describe "#fs_readfile" do
    let(:path)     { '/path/to/file' }
    let(:contents) { "foo bar\nbaz qux\n"  }

    it "must run the 'cat <path>' command and return the file contents" do
      expect(subject).to receive(:command_exec).with('cat',path).and_return(contents)

      expect(subject.fs_readfile(path)).to eq(contents)
    end
  end

  describe "#fs_readlink" do
    let(:path)      { '/path/to/link'  }
    let(:dest_path) { 'path/to/file'   }
    let(:output)    { "#{dest_path}\n" }

    it "must run the 'readlink -f <path>' command and return the link's path" do
      expect(subject).to receive(:command_exec).with('readlink','-f',path).and_return(output)

      expect(subject.fs_readlink(path)).to eq(dest_path)
    end
  end

  describe "#fs_readdir" do
    let(:path) { '/path/to/dir'  }
    let(:entries) do
      %w[
        API_SPEC.md
        ChangeLog.md
        COPYING.txt
        examples
        Gemfile
        Gemfile.lock
        gemspec.yml
        lib
        Rakefile
        README.md
        ronin-post_ex.gemspec
        spec
        vendor
      ]
    end
    let(:output) { "#{entries.join("\n")}\n" }

    it "must run the 'ls <path>' command and return the directories entries" do
      expect(subject).to receive(:command_exec).with('ls',path).and_return(output)

      expect(subject.fs_readdir(path)).to eq(entries)
    end
  end

  describe "#fs_glob" do
    let(:pattern) { '*.md' }
    let(:entries) do
      %w[
        API_SPEC.md
        ChangeLog.md
        README.md
      ]
    end
    let(:output) { "#{entries.join("\n")}\n" }

    it "must run the 'ls <pattern>' command and return the matching paths" do
      expect(subject).to receive(:shell_exec).with("ls #{pattern}").and_return(output)

      expect(subject.fs_glob(pattern)).to eq(entries)
    end
  end

  describe "#fs_mktemp" do
    let(:basename) { 'ronin-XXXX.txt' }
    let(:tempfile) { 'ronin-LtFK.txt' }
    let(:output) { "#{tempfile}\n" }

    it "must run the 'mktemp <basename>' command and return the tempfile name" do
      expect(subject).to receive(:command_exec).with('mktemp',basename).and_return(output)

      expect(subject.fs_mktemp(basename)).to eq(tempfile)
    end
  end

  describe "#fs_mkdir" do
    let(:path) { '/path/to/new_dir' }

    it "must run the 'mkdir <pattern>' command" do
      expect(subject).to receive(:command_exec).with('mkdir',path)

      subject.fs_mkdir(path)
    end
  end

  describe "#fs_copy" do
    let(:src)  { '/path/to/src'  }
    let(:dest) { '/path/to/dest' }

    it "must run the 'cp -r <src> <dest>' command" do
      expect(subject).to receive(:command_exec).with('cp','-r',src,dest)

      subject.fs_copy(src,dest)
    end
  end

  describe "#fs_unlink" do
    let(:path) { '/path/to/file' }

    it "must run the 'rm <path>' command" do
      expect(subject).to receive(:command_exec).with('rm',path)

      subject.fs_unlink(path)
    end
  end

  describe "#fs_rmdir" do
    let(:path) { '/path/to/dir' }

    it "must run the 'rmdir <path>' command" do
      expect(subject).to receive(:command_exec).with('rmdir',path)

      subject.fs_rmdir(path)
    end
  end

  describe "#fs_move" do
    let(:src)  { '/path/to/src'  }
    let(:dest) { '/path/to/dest' }

    it "must run the 'mv <src> <dest>' command" do
      expect(subject).to receive(:command_exec).with('mv',src,dest)

      subject.fs_move(src,dest)
    end
  end

  describe "#fs_link" do
    let(:src)  { '/path/to/src'  }
    let(:dest) { '/path/to/dest' }

    it "must run the 'ln -s <src> <dest>' command" do
      expect(subject).to receive(:command_exec).with('ln','-s',src,dest)

      subject.fs_link(src,dest)
    end
  end

  describe "#fs_chgrp" do
    let(:group) { 'wheel' }
    let(:path)  { '/path/to/file' }

    it "must run the 'chgrp <group> <path>' command" do
      expect(subject).to receive(:command_exec).with('chgrp',group,path)

      subject.fs_chgrp(group,path)
    end
  end

  describe "#fs_chown" do
    let(:user) { 'root' }
    let(:path) { '/path/to/file' }

    it "must run the 'chown <user> <path>' command" do
      expect(subject).to receive(:command_exec).with('chown',user,path)

      subject.fs_chown(user,path)
    end
  end

  describe "#fs_chmod" do
    let(:mode)  { 0777 }
    let(:umask) { "%.4o" % mode }
    let(:path)  { '/path/to/file' }

    it "must run the 'chown <user> <path>' command" do
      expect(subject).to receive(:command_exec).with('chmod',umask,path)

      subject.fs_chmod(mode,path)
    end
  end

  describe "#fs_stat" do
    let(:path) { '/path/to/file' }
    let(:size) { 420 }
    let(:blocks) { 16 }
    let(:uid) { 1000 }
    let(:gid) { 1000 }
    let(:inode) { 12345 }
    let(:links) { 1 }
    let(:atime) { Time.at(1668608914) }
    let(:mtime) { Time.at(1668427627) }
    let(:ctime) { Time.at(1668427627) }
    let(:blocksize) { 1668427627 }

    let(:output) do
      "#{path} #{size} #{blocks} 81a4 #{uid} #{gid} fd01 #{inode} #{links} 0 0 #{atime.to_i} #{mtime.to_i} #{ctime.to_i} #{blocksize} 4096 unconfined_u:object_r:unlabeled_t:s0\n"
    end

    it "must run the 'stat -t <path>' command and return a Hash of parsed stat information" do
      expect(subject).to receive(:command_exec).with('stat','-t',path).and_return(output)

      expect(subject.fs_stat(path)).to eq(
        {
          path:      path,
          size:      size,
          blocks:    blocks,
          uid:       uid,
          gid:       gid,
          inode:     inode,
          links:     links,
          atime:     atime,
          mtime:     mtime,
          ctime:     ctime,
          blocksize: blocksize
        }
      )
    end
  end

  describe "#process_getpid" do
    let(:pid)    { 1234 }
    let(:output) { "#{pid}\n" }

    it "must run the 'echo $$' command and return the parsed PID" do
      expect(subject).to receive(:shell_exec).with('echo $$').and_return(output)

      expect(subject.process_getpid).to eq(pid)
    end
  end

  describe "#process_getppid" do
    let(:ppid)   { 1234 }
    let(:output) { "#{ppid}\n" }

    it "must run the 'echo $PPID' command and return the parsed PPID" do
      expect(subject).to receive(:shell_exec).with('echo $PPID').and_return(output)

      expect(subject.process_getppid).to eq(ppid)
    end
  end

  describe "#process_getuid" do
    let(:uid)    { 1000 }
    let(:output) { "#{uid}\n" }

    it "must run the 'id -u' command and return the parsed UID" do
      expect(subject).to receive(:command_exec).with('id','-u').and_return(output)

      expect(subject.process_getuid).to eq(uid)
    end
  end

  describe "#process_getgid" do
    let(:gid)    { 1000 }
    let(:output) { "#{gid}\n" }

    it "must run the 'id -g' command and return the parsed GID" do
      expect(subject).to receive(:command_exec).with('id','-g').and_return(output)

      expect(subject.process_getgid).to eq(gid)
    end
  end

  describe "#process_getgid" do
    let(:env) do
      {
        'FOO' => 'foo',
        'BAR' => 'bar'
      }
    end
    let(:output) do
      "#{env.keys[0]}=#{env.values[0]}\n#{env.keys[1]}=#{env.values[1]}\n"
    end

    it "must run the 'env' command and return the parsed env Hash" do
      expect(subject).to receive(:command_exec).with('env').and_return(output)

      expect(subject.process_environ).to eq(env)
    end
  end

  describe "#process_getenv" do
    let(:name)  { 'FOO' }
    let(:value) { 'foo bar baz' }
    let(:output) { "#{value}\n" }

    it "must run the 'echo $<name>' command and return the parsed value" do
      expect(subject).to receive(:shell_exec).with("echo $#{name}").and_return(output)

      expect(subject.process_getenv(name)).to eq(value)
    end
  end

  describe "#process_setenv" do
    let(:name)  { 'FOO' }
    let(:value) { 'foo bar baz' }

    it "must run the 'export <name>=<value>' command and return the parsed value" do
      expect(subject).to receive(:shell_puts).with("export #{name}=#{value}")

      subject.process_setenv(name,value)
    end
  end

  describe "#process_unsetenv" do
    let(:name) { 'FOO' }

    it "must run the 'unset <name>' command" do
      expect(subject).to receive(:shell_puts).with("unset #{name}")

      subject.process_unsetenv(name)
    end
  end

  describe "#process_kill" do
    let(:pid)    { 1234   }
    let(:signal) { 'TERM' }

    it "must run the 'kill -s <signal> <pid>' command" do
      expect(subject).to receive(:command_exec).with('kill','-s',signal,pid)

      subject.process_kill(pid,signal)
    end
  end

  describe "#process_spawn" do
    let(:command_name) { 'cmd' }
    let(:arguments)    { ['foo', 'bar baz'] }

    let(:pid)    { 1234 }
    let(:output) { "#{pid}\n" }

    it "must run the command with arguments and return the parsed PID" do
      command = Shellwords.join([command_name, *arguments])

      expect(subject).to receive(:shell_exec).with("#{command} 2>&1 >/dev/null &; echo $!").and_return(output)

      expect(subject.process_spawn(command_name,*arguments)).to eq(pid)
    end
  end

  describe "#process_exit" do
    it "must run the 'exit' command" do
      expect(subject).to receive(:shell_puts).with('exit')

      subject.process_exit
    end
  end

  describe "#close" do
    it "must call #close on #io" do
      expect(io).to receive(:close)

      subject.close
    end
  end
end
