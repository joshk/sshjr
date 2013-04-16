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
    #   auth = SSHJr::Auth::PublicKey.new(
    #     'johndoe',
    #     '/opt/app/keys/ssh',
    #     'secret'
    #   )
    #   client.authenticate(auth)
    class PublicKey
      # Public: Initialize a PublicKey authentication object.
      #
      # username   - The username to authenticate as.
      # location   - The file path location of the private key. A public key is
      #              expected to be in a file of the same name with '.pub'
      #              appended.
      # passphrase - The passphrase used to encrypt the public key.
      def initialize(username, location, passphrase=nil)
        @username = username
        @location = location
        @passphrase = passphrase
      end

      # Internal: Apply the authentication method to the given client
      #
      # client - The SSHClient object representing the client.
      #
      # Returns nothing.
      # Raises AuthenticationError if an authentication failure occured.
      # Raises TransportException if a transport-layer error occured.
      def authenticate(client)
        client.auth_publickey(@username, client.load_keys(@location, @passphrase))
      rescue Java::NetSchmizzSshjUserauth::UserAuthException => e
        raise AuthenticationError, e.message
      end

      def inspect
        "#<#{self.class.name} " +
          "username:#{@username.inspect} " +
          "location:#{@location.inspect} " +
          "passphrase:#{@passphrase.gsub(/./, '*').inspect}>"
      end
    end
  end
end
