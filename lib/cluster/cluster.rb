class Central
  class Cluster
    def initialize(name, environment, *servers)
      @name = name
      @environment = environment
      ## server list is supposedly retrieved from a data store and injected here
      @servers ||= []
      @servers << Central::Server.new("nagios", "echo 'whoami deploying Nagios ...'")
      @servers << Central::Server.new("percona_master", "echo 'chef deploying Percona Master ...'")
      @servers << Central::Server.new("percona_slave", "echo 'chef deploying Percona Slave ...'")
    end

    def deploy
      Central.redis.sadd "environments::#{@environment}::clusters", "#{@name}"
      Central.debug "Deploying cluster #{@environment}-#{@name} with #{@servers.size} servers"
            
      @servers.map do |server| 
        Resque.enqueue(Central::Server, Central.counter, server.deploy_command, {:trackers => ["command::DeployCluster"]})
      end
    end
  end
end