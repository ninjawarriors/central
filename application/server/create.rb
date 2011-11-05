module Central
  module ServerCreate
    @queue = :server
  
    def self.perform(name, options = {})
      sleep 1
      puts "Creating Server: #{name}"
    end
  
    def self.after_batch_actions(name, options = {})
      # Do something interesting
    end
  end
  
  module ClusterCreate
    @queue = :cluster
  
    def self.perform(name, options = {})
      sleep 1
      puts "Creating Cluster: #{name}"
    end
  
    def self.after_batch_actions(name, options = {})
      # Do something interesting
    end
  end
end
