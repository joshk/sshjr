module Jsshj
  class SessionChannel
    import 'net.schmizz.sshj.connection.channel.direct.PTYMode'

    def allocate_echoless_pty
      allocate_pty("xterm", 80, 24, 640, 480, { PTYMode::ECHO => java.lang.Integer.new(0) })
    end

    def start_interactive_shell(echoless = true)
      allocate_echoless_pty
      shell = start_shell
      if echoless
        out = shell.output_stream
        out.write("export PS1=; echo #{separator} $?\n".to_java_bytes)
        out.flush
      end
      shell
    end
  end
end