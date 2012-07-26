module Jsshj
  class InteractiveShell
    def separator
      @separator ||= begin
        s = Digest::SHA1.hexdigest([object_id, Time.now.to_i, Time.now.usec, rand(0xFFFFFFFF)].join(":"))
        s << Digest::SHA1.hexdigest(s)
      end
    end

    def send_command(command, out, separator)
      cmd = command.dup
      cmd << ";" if cmd !~ /[;&]$/
      cmd << " DONTEVERUSETHIS=$?; echo #{separator} $DONTEVERUSETHIS; echo \"exit $DONTEVERUSETHIS\"|sh"

      out.write("#{cmd}\n".to_java_bytes)
      out.flush
    end
  end
end