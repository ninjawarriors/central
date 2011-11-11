class Central
  module ClusterCreate
    @queue = :cluster

    def self.perform(name, options = {})
      sleep 1
      Central.debug "Creating Cluster: #{name}"
    end

    def self.after_batch_actions(name, options = {})
      # Do something interesting
    end
  end
end
