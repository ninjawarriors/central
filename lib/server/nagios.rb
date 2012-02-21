class NagiosServer < Central::Server
  @name = "Nagios"
  @deploy_command = "echo 'hey this is a #{@name} server to deploy'"
end
