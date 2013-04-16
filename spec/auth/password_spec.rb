require 'spec_helper'
require 'sshjr/auth/password'

describe SSHJr::Auth::Password do
  describe '#authenticate' do
    it 'calls auth_password on the client' do
      client = double('client')
      client.should_receive(:auth_password).with('johndoe', 'secret')
      described_class.new('johndoe', 'secret').authenticate(client)
    end
  end
end