require 'sshjr/command'
require 'sshjr/keys/blindly_accepting_host_key_verifier'

module SSHJr
  # Wraps a connection to a server
  #
  # This is probably one of the first classes you will be interacting with when
  # using SSHJr. It's responsible for setting up a connection to the server and
  #
  # Example:
  #
  #   client = SSHJr::Client.new
  #   client.connect('example.com')
  #   client.authenticate(authentication_method)
  #   command = client.exec_with_pty('echo Hello World')
  class Client
    class AuthenticationError < StandardError; end

    # Public: Connect to the server with the given connection details.
    #
    # hostname - The hostname or IP address to connect to.
    # port     - The port the SSH server is running on (default: 22).
    #
    # Returns nothing.
    # Raises IOError if there was an error connecting to the server.
    def connect(hostname, port=22)
      client.connect(hostname, port)
    rescue java.io.IOException => e
      raise IOError, e.message
    end

    # Public: Returns whether or not we are connected to the SSH server.
    def connected?
      client.connected?
    end

    # Authenticate the session with a given authentication method
    #
    # authentication_method - The authentication method to use. See SSHJr::Auth
    #                         for available authentication methods.
    #
    # Returns nothing.
    # Raises AuthenticationError if there was an error authenticating with the
    #   given authentication method.
    def authenticate(authentication_method)
      authentication_method.authenticate(client)
    end

    def exec_with_pty(command)
      session = client.start_session
      session.allocate_default_pty
      Command.new(session.exec(command))
    end

    # Public: Disconnect from the connected SSH server
    #
    # This method should be called from an `ensure` block to properly clean up
    # everything, including the thread spawned to deal with incoming packets.
    #
    # Returns nothing.
    def close
      client.close
    end

    private

    # Internal: The sshj Java SSH client backend instance.
    def client
      @client ||= Java::NetSchmizzSshj::SSHClient.new.tap do |client|
        # TODO: Expose host key verification through an API
        client.add_host_key_verifier(Keys::BlindlyAcceptingHostKeyVerifier.new)
      end
    end
  end
end
