require 'spec_helper'
require 'socket'

class FakeSocket
  def initialize(contents)
    @server = setup_server
    @thread = Thread.new { loop { process } }
    @contents = contents
  end

  def to_io
    TCPSocket.new('localhost', @port)
  end

  def stop
    @thread.exit
  end

  private

  def setup_server
    retries = 0
    @port = next_port
    TCPServer.new('localhost', @port)
  rescue Errno::EADDRINUSE
    retry if (retries += 1) <= 5
  end

  def process
    socket = @server.accept
    socket.print(@contents)
    socket.close_read
    socket.close_write
  end

  def next_port
    @port ||= 4000
    @port += 1
  end
end

describe SSHJr::Command do
  def io(contents)
    FakeSocket.new(contents).tap do |socket|
      @sockets << socket
    end
  end

  let(:foobar_io) { io('foobar') }
  let(:empty_io) { io('') }
  let(:long_io) { io('.' * 10_000) }
  let(:java_command) { double('Session.Command', exit_status: 0, input_stream: empty_io, error_stream: empty_io, close: nil) }
  let(:command) { described_class.new(java_command) }

  before(:each) do
    @sockets = []
  end

  after(:each) do
    @sockets.each(&:stop)
  end

  before(:each) do
    @buffer = String.new
    command.on_output { |str| @buffer << str }
  end

  describe '#process' do
    it 'returns the exit status' do
      expect(command.process).to eq(0)
    end

    it 'calls the output block when output is received' do
      java_command.stub(input_stream: foobar_io)
      command.process
      expect(@buffer).to eq('foobar')
    end

    it 'calls the output block when output is received for stderr' do
      java_command.stub(error_stream: foobar_io)
      command.process
      expect(@buffer).to eq('foobar')
    end

    it 'exits early if the given block returns true' do
      java_command.stub(input_stream: long_io)
      command.process { true }
      expect(@buffer.length).to be > 0
      expect(@buffer.length).to be < File.size(File.expand_path('../fixtures/long', __FILE__))
    end
  end
end
