require "spec_helper"
require "pathname"


describe SSHJr::Client, "with all-accepting host key verifier" do
  let(:hostname) { ENV["SSHTEST_HOSTNAME"] }
  let(:username) { ENV["SSHTEST_USERNAME"] }
  let(:password) { ENV["SSHTEST_PASSWORD"] }
  let(:port)     { ENV["SSHTEST_PORT"].to_i }

  let(:rsa_key_path) { Pathname.getwd.join("spec", "keys", "key1_rsa") }
  let(:dsa_key_path) { Pathname.getwd.join("spec", "keys", "key2_dsa") }
  let(:key_paths)    { [rsa_key_path, dsa_key_path] }

  context "with correct password credentials" do
    xit "connects successfully" do
      client = SSHJr::Client.start(hostname, username, :password => password, :port => port)

      client.should be_connected
      client.close
    end

    xit "opens a session successfully" do
      client  = SSHJr::Client.start(hostname, username, :password => password, :port => port)
      session = client.start_session

      session.should be_open
      session.close
      client.close
    end

    xit "executes a command successfully" do
      client  = SSHJr::Client.start(hostname, username, :password => password, :port => port)
      session = client.start_session

      result  = session.exec "ping -c 1 google.com"
      output  = result.input_stream.to_io.readlines
      output.should be =~ /PING google.com/

      session.close
      client.close
    end

    xit "gets the status code" do
      client  = SSHJr::Client.start(hostname, username, :password => password, :port => port)
      session = client.start_session

      result  = session.exec "echo foobar"
      result.join
      result.exit_status.should be 0

      session.close
      client.close
    end
  end

  context "with correct key credentials" do
    xit "connects successfully" do
      client = SSHJr::Client.start(hostname, username, :private_key_paths => key_paths)

      client.should be_connected
      client.close
    end
  end
end
