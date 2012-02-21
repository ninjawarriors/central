class PerconaMasterServer < Central::Server
  @name = "Percona Master"
  @deploy_command = "echo 'hey this is a #{@name} server to deploy'"
end
