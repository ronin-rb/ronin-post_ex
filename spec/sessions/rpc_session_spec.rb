require 'spec_helper'
require 'ronin/post_ex/sessions/rpc_session'

describe Ronin::PostEx::Sessions::RPCSession do
  let(:rpc_client) { double('RPC Client') }

  subject { described_class.new(rpc_client) }

  describe "#initialize" do
    it "must set #client" do
      expect(subject.client).to be(rpc_client)
    end
  end

  let(:response) { double('response value') }

  describe "#sys_time" do
    it "must call 'sys.time'" do
      expect(rpc_client).to receive(:call).with('sys.time').and_return(response)

      expect(subject.sys_time).to be(response)
    end
  end

  describe "#file_open" do
    let(:path) { '/path/to/file' }

    it "must call 'file.open' with a path and 'r' arguments" do
      expect(rpc_client).to receive(:call).with('file.open',path,'r').and_return(response)

      expect(subject.file_open(path)).to be(response)
    end

    context "when given the additional mode argument" do
      let(:mode) { 'rb' }

      it "must call 'file.open' with a path and mode arguments" do
        expect(rpc_client).to receive(:call).with('file.open',path,mode).and_return(response)

        expect(subject.file_open(path,mode)).to be(response)
      end
    end
  end

  describe "#file_read" do
    let(:fd)     { double('fd')     }
    let(:length) { double('length') }

    it "must call 'file.read' with a length arguments" do
      expect(rpc_client).to receive(:call).with('file.read',fd,length).and_return(response)

      expect(subject.file_read(fd,length)).to be(response)
    end
  end

  describe "#file_write" do
    let(:fd)   { double('fd')   }
    let(:pos)  { double('pos')  }
    let(:data) { double('data') }

    it "must call 'file.read' with fd, pos, and data arguments" do
      expect(rpc_client).to receive(:call).with('file.write',fd,pos,data).and_return(response)

      expect(subject.file_write(fd,pos,data)).to be(response)
    end
  end

  describe "#file_seek" do
    let(:fd)      { double('fd')      }
    let(:new_pos) { double('new_pos') }
    let(:whence)  { double('whence')  }

    it "must call 'file.seek' with fd, new_pos, and whence arguments" do
      expect(rpc_client).to receive(:call).with('file.seek',fd,new_pos,whence).and_return(response)

      expect(subject.file_seek(fd,new_pos,whence)).to be(response)
    end
  end

  describe "#file_tell" do
    let(:fd) { double('fd') }

    it "must call 'file.seek' with a fd argument" do
      expect(rpc_client).to receive(:call).with('file.tell',fd).and_return(response)

      expect(subject.file_tell(fd)).to be(response)
    end
  end

  describe "#file_ioctl" do
    let(:fd)       { double('fd')       }
    let(:command)  { double('command')  }
    let(:argument) { double('argument') }

    it "must call 'file.ioctl' with a fd, command, and 'argument' arguments" do
      expect(rpc_client).to receive(:call).with('file.ioctl',fd,command,argument).and_return(response)

      expect(subject.file_ioctl(fd,command,argument)).to be(response)
    end
  end

  describe "#file_fcntl" do
    let(:fd)       { double('fd')       }
    let(:command)  { double('command')  }
    let(:argument) { double('argument') }

    it "must call 'file.fcntl' with a fd, command, and 'argument' arguments" do
      expect(rpc_client).to receive(:call).with('file.fcntl',fd,command,argument).and_return(response)

      expect(subject.file_fcntl(fd,command,argument)).to be(response)
    end
  end

  describe "#file_stat" do
    let(:fd) { double('fd') }

    it "must call 'file.stat' with a fd argument" do
      expect(rpc_client).to receive(:call).with('file.stat',fd).and_return(response)

      expect(subject.file_stat(fd)).to be(response)
    end
  end

  describe "#file_close" do
    let(:fd) { double('fd') }

    it "must call 'file.fcntl' with a fd argument" do
      expect(rpc_client).to receive(:call).with('file.close',fd).and_return(response)

      expect(subject.file_close(fd)).to be(response)
    end
  end

  describe "#fs_gtecwd" do
    it "must call 'fs.getcwd'" do
      expect(rpc_client).to receive(:call).with('fs.getcwd').and_return(response)

      expect(subject.fs_getcwd).to be(response)
    end
  end

  describe "#fs_chdir" do
    let(:path) { double('path') }

    it "must call 'fs.chdir' with a path argument" do
      expect(rpc_client).to receive(:call).with('fs.chdir',path).and_return(response)

      expect(subject.fs_chdir(path)).to be(response)
    end
  end

  describe "#fs_readfile" do
    let(:path) { double('path') }

    it "must call 'fs.readfile' with a path argument" do
      expect(rpc_client).to receive(:call).with('fs.readfile',path).and_return(response)

      expect(subject.fs_readfile(path)).to be(response)
    end
  end

  describe "#fs_readlink" do
    let(:path) { double('path') }

    it "must call 'fs.readlink' with a path argument" do
      expect(rpc_client).to receive(:call).with('fs.readlink',path).and_return(response)

      expect(subject.fs_readlink(path)).to be(response)
    end
  end

  describe "#fs_readdir" do
    let(:path) { double('path') }

    it "must call 'fs.readdir' with a path argument" do
      expect(rpc_client).to receive(:call).with('fs.readdir',path).and_return(response)

      expect(subject.fs_readdir(path)).to be(response)
    end
  end

  describe "#fs_glob" do
    let(:pattern) { double('pattern') }

    it "must call 'fs.glob' with a pattern argument" do
      expect(rpc_client).to receive(:call).with('fs.glob',pattern).and_return(response)

      expect(subject.fs_glob(pattern)).to be(response)
    end
  end

  describe "#fs_mktemp" do
    let(:basename) { double('basename') }

    it "must call 'fs.mktemp' with a basename argument" do
      expect(rpc_client).to receive(:call).with('fs.mktemp',basename).and_return(response)

      expect(subject.fs_mktemp(basename)).to be(response)
    end
  end

  describe "#fs_mkdir" do
    let(:new_path) { double('new_path') }

    it "must call 'fs.mkdir' with a new_path argument" do
      expect(rpc_client).to receive(:call).with('fs.mkdir',new_path).and_return(response)

      expect(subject.fs_mkdir(new_path)).to be(response)
    end
  end

  describe "#fs_copy" do
    let(:src)  { double('src')  }
    let(:dest) { double('dest') }

    it "must call 'fs.copy' with src and dest arguments" do
      expect(rpc_client).to receive(:call).with('fs.copy',src,dest).and_return(response)

      expect(subject.fs_copy(src,dest)).to be(response)
    end
  end

  describe "#fs_unlink" do
    let(:path)  { double('path') }

    it "must call 'fs.unlink' with a path arguments" do
      expect(rpc_client).to receive(:call).with('fs.unlink',path).and_return(response)

      expect(subject.fs_unlink(path)).to be(response)
    end
  end

  describe "#fs_rmdir" do
    let(:path)  { double('path') }

    it "must call 'fs.rmdir' with a path arguments" do
      expect(rpc_client).to receive(:call).with('fs.rmdir',path).and_return(response)

      expect(subject.fs_rmdir(path)).to be(response)
    end
  end

  describe "#fs_move" do
    let(:src)  { double('src')  }
    let(:dest) { double('dest') }

    it "must call 'fs.move' with src and dest arguments" do
      expect(rpc_client).to receive(:call).with('fs.move',src,dest).and_return(response)

      expect(subject.fs_move(src,dest)).to be(response)
    end
  end

  describe "#fs_link" do
    let(:src)  { double('src')  }
    let(:dest) { double('dest') }

    it "must call 'fs.link' with src and dest arguments" do
      expect(rpc_client).to receive(:call).with('fs.link',src,dest).and_return(response)

      expect(subject.fs_link(src,dest)).to be(response)
    end
  end

  describe "#fs_chgrp" do
    let(:group) { double('group') }
    let(:path)  { double('path')  }

    it "must call 'fs.chgrp' with group and path arguments" do
      expect(rpc_client).to receive(:call).with('fs.chgrp',group,path).and_return(response)

      expect(subject.fs_chgrp(group,path)).to be(response)
    end
  end

  describe "#fs_chown" do
    let(:user) { double('user') }
    let(:path) { double('path') }

    it "must call 'fs.chown' with user and path arguments" do
      expect(rpc_client).to receive(:call).with('fs.chown',user,path).and_return(response)

      expect(subject.fs_chown(user,path)).to be(response)
    end
  end

  describe "#fs_chmod" do
    let(:mode) { double('mode') }
    let(:path) { double('path') }

    it "must call 'fs.chmod' with mode and path arguments" do
      expect(rpc_client).to receive(:call).with('fs.chmod',mode,path).and_return(response)

      expect(subject.fs_chmod(mode,path)).to be(response)
    end
  end

  describe "#fs_stat" do
    let(:path) { double('path') }

    it "must call 'fs.stat' with a path argument" do
      expect(rpc_client).to receive(:call).with('fs.stat',path).and_return(response)

      expect(subject.fs_stat(path)).to be(response)
    end
  end

  describe "#process_getpid" do
    it "must call 'process.getpid'" do
      expect(rpc_client).to receive(:call).with('process.getpid').and_return(response)

      expect(subject.process_getpid).to be(response)
    end
  end

  describe "#process_getppid" do
    it "must call 'process.getppid'" do
      expect(rpc_client).to receive(:call).with('process.getppid').and_return(response)

      expect(subject.process_getppid).to be(response)
    end
  end

  describe "#process_getuid" do
    it "must call 'process.getuid'" do
      expect(rpc_client).to receive(:call).with('process.getuid').and_return(response)

      expect(subject.process_getuid).to be(response)
    end
  end

  describe "#process_setuid" do
    let(:uid) { double('uid') }

    it "must call 'process.setuid' with a uid argument" do
      expect(rpc_client).to receive(:call).with('process.setuid',uid).and_return(response)

      expect(subject.process_setuid(uid)).to be(response)
    end
  end

  describe "#process_geteuid" do
    it "must call 'process.geteuid'" do
      expect(rpc_client).to receive(:call).with('process.geteuid').and_return(response)

      expect(subject.process_geteuid).to be(response)
    end
  end

  describe "#process_seteuid" do
    let(:euid) { double('euid') }

    it "must call 'process.seteuid' with a euid argument" do
      expect(rpc_client).to receive(:call).with('process.seteuid',euid).and_return(response)

      expect(subject.process_seteuid(euid)).to be(response)
    end
  end

  describe "#process_getgid" do
    it "must call 'process.getgid'" do
      expect(rpc_client).to receive(:call).with('process.getgid').and_return(response)

      expect(subject.process_getgid).to be(response)
    end
  end

  describe "#process_setgid" do
    let(:gid) { double('gid') }

    it "must call 'process.setgid' with a gid argument" do
      expect(rpc_client).to receive(:call).with('process.setgid',gid).and_return(response)

      expect(subject.process_setgid(gid)).to be(response)
    end
  end

  describe "#process_getegid" do
    it "must call 'process.getegid'" do
      expect(rpc_client).to receive(:call).with('process.getegid').and_return(response)

      expect(subject.process_getegid).to be(response)
    end
  end

  describe "#process_setegid" do
    let(:egid) { double('egid') }

    it "must call 'process.setegid' with a egid argument" do
      expect(rpc_client).to receive(:call).with('process.setegid',egid).and_return(response)

      expect(subject.process_setegid(egid)).to be(response)
    end
  end

  describe "#process_getsid" do
    it "must call 'process.getsid'" do
      expect(rpc_client).to receive(:call).with('process.getsid').and_return(response)

      expect(subject.process_getsid).to be(response)
    end
  end

  describe "#process_setsid" do
    let(:sid) { double('sid') }

    it "must call 'process.setsid' with a sid argument" do
      expect(rpc_client).to receive(:call).with('process.setsid',sid).and_return(response)

      expect(subject.process_setsid(sid)).to be(response)
    end
  end

  describe "#process_environ" do
    it "must call 'process.environ'" do
      expect(rpc_client).to receive(:call).with('process.environ').and_return(response)

      expect(subject.process_environ).to be(response)
    end
  end

  describe "#process_getenv" do
    let(:name) { double('name') }

    it "must call 'process.getenv' with a name argument" do
      expect(rpc_client).to receive(:call).with('process.getenv',name).and_return(response)

      expect(subject.process_getenv(name)).to be(response)
    end
  end

  describe "#process_getenv" do
    let(:name)  { double('name')  }
    let(:value) { double('value') }

    it "must call 'process.setenv' with name and value arguments" do
      expect(rpc_client).to receive(:call).with('process.setenv',name,value).and_return(response)

      expect(subject.process_setenv(name,value)).to be(response)
    end
  end

  describe "#process_unsetenv" do
    let(:name) { double('name') }

    it "must call 'process.unsetenv' with a name argument" do
      expect(rpc_client).to receive(:call).with('process.unsetenv',name).and_return(response)

      expect(subject.process_unsetenv(name)).to be(response)
    end
  end

  describe "#process_kill" do
    let(:pid)    { double('pid')    }
    let(:signal) { double('signal') }

    it "must call 'process.kill' with pid and signal arguments" do
      expect(rpc_client).to receive(:call).with('process.kill',pid,signal).and_return(response)

      expect(subject.process_kill(pid,signal)).to be(response)
    end
  end

  describe "#process_spawn" do
    let(:program)   { double('program') }
    let(:arguments) { [double('arg1'), double('arg2')] }

    it "must call 'process.spawn' with program and 'arguments' arguments" do
      expect(rpc_client).to receive(:call).with('process.spawn',program,*arguments).and_return(response)

      expect(subject.process_spawn(program,*arguments)).to be(response)
    end
  end

  describe "#process_exit" do
    it "must call 'process.exit'" do
      expect(rpc_client).to receive(:call).with('process.exit').and_return(response)

      expect(subject.process_exit).to be(response)
    end
  end

  describe "#shell_exec" do
    let(:command) { double('command') }

    it "must call 'shell.exec' with a command argument" do
      expect(rpc_client).to receive(:call).with('shell.exec',command).and_return(response)

      expect(subject.shell_exec(command)).to be(response)
    end
  end
end
