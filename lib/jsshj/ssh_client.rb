require 'jsshj/client/blindly_accepting_host_key_verifier'

module Jsshj
  class SSHClient
    def accept_all_hosts
      self.add_host_key_verifier(Jsshj::Client::BlindlyAcceptingHostKeyVerifier.new)
    end
  end
end
