module Jsshj
  module Client
    class BlindlyAcceptingHostKeyVerifier
      def verify(host, port, key)
       true
      end
    end
  end
end
