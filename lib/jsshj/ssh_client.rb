require 'jsshj/all_hosts_key_verifier'

module Jsshj
  class SSHClient
    def accept_all_hosts
      self.add_host_key_verifier(AllHostKeyVerifier.new)
    end
  end
end