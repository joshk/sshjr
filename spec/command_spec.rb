require 'spec_helper'
require 'stringio'

describe SSHJr::Command do
  let(:foobar_io) { double(to_io: File.open(File.expand_path('../fixtures/foobar', __FILE__), 'r')) }
  let(:empty_io) { double(to_io: File.open(File.expand_path('../fixtures/empty', __FILE__), 'r')) }
  let(:long_io) { double(to_io: File.open(File.expand_path('../fixtures/long', __FILE__), 'r')) }
  let(:java_command) { double('Session.Command', exit_status: 0, input_stream: empty_io, error_stream: empty_io, close: nil) }
  let(:command) { described_class.new(java_command) }

  describe '#process' do
    it 'returns the exit status' do
      expect(command.process).to eq(0)
    end

    it 'calls the output block when output is received' do
      java_command.stub(input_stream: foobar_io)
      buffer = ''
      command.on_output { |str| buffer << str }
      command.process
      expect(buffer).to eq('foobar')
    end

    it 'calls the output block when output is received for stderr' do
      java_command.stub(error_stream: foobar_io)
      buffer = ''
      command.on_output { |str| buffer << str }
      command.process
      expect(buffer).to eq('foobar')
    end

    it 'exits early if the given block returns true' do
      java_command.stub(input_stream: long_io)
      buffer = ''
      command.on_output { |str| buffer << str }
      command.process { true }
      expect(buffer.length).to be < File.size(File.expand_path('../fixtures/long', __FILE__))
    end
  end
end