import 'net.schmizz.sshj.common.IOUtils'
import 'java.util.concurrent.TimeUnit'
import 'net.schmizz.sshj.common.Buffer'

def capture_output(io)
  Thread.new do
    puts "output stream finished"
  end
end

require 'thread'
require 'mutex_m'
class Buffer
  include Mutex_m

  attr_reader :input, :separator

  def initialize(input, separator)
    @input = input
    @separator = separator
    @subscribers = []
    start_consuming
  end

  def start_consuming
    @consumer = Thread.new do
      while !input.eof? && data = input.readpartial(1024)
        if data.strip =~ /#{separator} (\d+)$/
          separatorless = $`
          publish(separatorless) unless separatorless.empty?
          puts "command exited with #{$1}"
        else
          publish(data)
        end
      end
    end
  end

  def stop_consuming
    @consumer.exit
  end

  def publish(data)
    @subscribers.each { |s| s.print(data) }
  end

  def eof?
    input.eof?
  end

  def subscribe(subscriber)
    @subscribers << subscriber
  end
end

def separator
  @separator ||= begin
    s = Digest::SHA1.hexdigest([object_id, Time.now.to_i, Time.now.usec, rand(0xFFFFFFFF)].join(":"))
    s << Digest::SHA1.hexdigest(s)
  end
end

require 'jsshj'

ssh  = Jsshj::SSHClient.new
ssh.accept_all_hosts
ssh.connect("67.214.220.219")
ssh.auth_password('travis', 'yumyumyum123!@#')

session = ssh.start_session

shell = session.start_echoless_shell

buffer = Buffer.new(shell.input_stream.to_io, separator)

out = shell.output_stream

buffer.subscribe($stdout)
capture_output(io)

send_command("cd /usr", out, separator)
send_command("ls", out, separator)
send_command("echo mkdir yum\n mkdir yum", out, separator)
send_command("echo ping -c 10 google.com\n ping -c 10 google.com", out, separator)

puts "the exit status is : #{cmd.exit_status}"
session.close


ssh.disconnect
