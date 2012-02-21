class Central
class Cluster
  @queue = :cluster_create
    def create
      servers = [ Central::Server::NagiosServer.new,
                Central::Server::PerconaMasterServer.new,
                Central::Server::PerconaSlaveServer.new
              ]
      servers.map do |server| 
        puts "creating for #{klass}"
        Resque.enqueue(server, Central.counter, {:trackers => ["command::DeployCluster"]})
      end
    end
end
end