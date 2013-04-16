require "spec_helper"
require "pathname"

describe SSHJr::Client do
  subject { described_class.new }
  let(:hostname) { 'example.com' }
  let(:port) { 22 }
  let(:client) { double('client') }

  before(:each) do
    subject.instance_variable_set(:@client, client)
  end

  describe '#connect' do
    it 'calls the implementation' do
      client.should_receive(:connect).with(hostname, port)
      subject.connect(hostname, port)
    end
  end
end
