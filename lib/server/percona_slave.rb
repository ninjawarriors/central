class PerconaSlaveServer < Central::Server 
  @name = "Percona slave"
  @deploy_command = "echo 'hey this is a #{@name} server to deploy'"
end
