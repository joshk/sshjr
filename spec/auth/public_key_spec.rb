require 'spec_helper'
require 'sshjr/auth/public_key'

describe SSHJr::Auth::PublicKey do
  describe '#authenticate' do
    it 'calls auth_publickey on the client' do
      key_provider = double('key_provider')
      client = double('client')
      client.should_receive(:load_keys).with('~/.ssh/id_rsa', 'secret') { key_provider }
      client.should_receive(:auth_publickey).with('johndoe', key_provider)
      described_class.new('johndoe', '~/.ssh/id_rsa', 'secret').authenticate(client)
    end
  end
end