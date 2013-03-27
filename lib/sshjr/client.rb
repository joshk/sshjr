require "sshjr/keys/blindly_accepting_host_key_verifier"
require 'sshjr/command'

module SSHJr
  import 'net.schmizz.sshj.SSHClient'

  class Client

    #
    # API
    #

    def self.start(*args)
      new(*args)
    end

    def initialize(hostname, username, options = {})
      @hostname = hostname
      @username = username

      @impl     = SSHClient.new

      add_host_verifier(@impl, options)
      options[:port] ? @impl.connect(hostname, options[:port]) : @impl.connect(hostname)
      authenticate(@impl, username, options)
    end

    def exec_with_pty(command)
      session = @impl.start_session
      session.allocate_default_pty
      Command.new(session.exec(command))
    end

    def connected?
      @impl.connected?
    end

    def close
      @impl.close
    end


    protected

    def authenticate(sshj_client, username, options)
      if pwd = options[:password]
        sshj_client.auth_password(username, pwd)
      elsif (key_paths = filter_paths(options[:private_key_paths])).any?
        sshj_client.auth_publickey(username, key_paths.to_java(:string))
      else
        raise ArgumentError, "Cannot perform authentication: either :private_key_paths or :password must be give to SSHJr::Client.start and SSHJr::Client#initialize."
      end
    end

    def add_host_verifier(sshj_client, options)
      verifier = options.fetch(:host_key_verifier, Keys::BlindlyAcceptingHostKeyVerifier.new)

      sshj_client.add_host_key_verifier(verifier)
    end

    def filter_paths(xs)
      if xs
        xs.select { |x| File.exists?(x) }.map {|x| x.to_s}
      else
        []
      end
    end
  end
end
