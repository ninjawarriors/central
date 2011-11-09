module ClusterCreate
  extend Central
  @queue = :cluster

  def self.perform(name, options = {})
    sleep 1
    debug "Creating Cluster: #{name}"
  end

  def self.after_batch_actions(name, options = {})
    # Do something interesting
  end
end
