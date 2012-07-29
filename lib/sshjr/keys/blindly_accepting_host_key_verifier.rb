module SSHJr
  module Keys
    class BlindlyAcceptingHostKeyVerifier
      def verify(host, port, key)
       true
      end
    end
  end
end
