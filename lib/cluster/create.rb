class Central
  module ClusterCreate
    @queue = :cluster

    def self.perform(name, options = {})
      started = Time.now.to_i
      sleep 1
      error = nil
      stdout = RedisTailer.new id, "stdout"
      stderr = RedisTailer.new id, "stderr"
      Central.debug "Creating Cluster: #{name}"
      command = "knife client list | grep test"
      begin
        status = spawn command, 'stdout' => stdout, 'stderr' => stderr
      rescue  => e
        error = e
      end
      finished = Time.now.to_i
      Central.redis.lpush "logs::cluster::run", id
      Central.redis.set "logs::#{id}", { :id => id, :status => status.to_i, :error => error, :command => command, :started => started, :finished => finished }.to_json
      if DEBUG
        puts command
        puts status.to_i
        puts stdout
        puts stderr if stderr
      end
    end

    def self.after_batch_actions(name, options = {})
      # Do something interesting
    end
  end
end
