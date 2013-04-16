require 'sshjr/errors'

module SSHJr
  module Auth
    # Public: Password authentication method
    #
    # Use this in order to authenticate an SSH session with a username and a
    # password.
    #
    # Examples:
    #
    #   auth = SSHJr::Auth::Password.new('johndoe', 'secret')
    #   client.authenticate(auth)
    class Password
      # Public: Initialize a Password authentication object.
      #
      # username - The username to authenticate as.
      # password - The password to authenticate with
      def initialize(username, password)
        @username = username
        @password = password
      end

      # Internal: Apply the authentication method to the given client
      #
      # client - The SSHClient object representing the client.
      #
      # Returns nothing.
      # Raises UserAuthException if an authentication failure occured.
      # Raises TransportException if a transport-layer error occured.
      def authenticate(client)
        client.auth_password(@username, @password)
      rescue Java::NetSchmizzSshjUserauth::UserAuthException => e
        raise AuthenticationError, e.message
      end

      def inspect
        "#<#{self.class.name} username:#{@username.inspect} password:#{@password.gsub(/./, '*').inspect}>"
      end
    end
  end
end
