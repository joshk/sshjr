require 'java'
require 'vendor/slf4j-api'
require 'vendor/bcprov-jdk15on-147'
require 'vendor/bcpkix-jdk15on-147'
require 'vendor/sshj'

module Jsshj
  import 'net.schmizz.sshj.SSHClient'
  import 'net.schmizz.sshj.connection.channel.direct.SessionChannel'

  # import 'net.schmizz.sshj.common.IOUtils'
  # import 'net.schmizz.sshj.connection.channel.direct.Session'
  # import 'net.schmizz.sshj.connection.channel.direct.Session.Command'
end

require 'jsshj/ssh_client'
require 'jsshj/session_channel'