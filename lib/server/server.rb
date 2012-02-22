class Central
  class Server
    attr_accessor :name, :deploy_command

    @queue = :server_deployment

    def initialize(name=name, deploy_command=deploy_command)
      @name = name
      @deploy_command = deploy_command
    end

    def self.perform(id, command, options = {})
      started = Time.now.to_i
      Central.debug "Running Arbitrary Command ID: #{id} --- #{command}"
      error = nil
      stdout = RedisTailer.new id, "stdout"
      stderr = RedisTailer.new id, "stderr"
      #status = systemu command, 'stdout' => stdout, 'stderr' => stderr
      begin
        status = spawn command, 'stdout' => stdout, 'stderr' => stderr
      rescue => e
        error = e
      end
      finished = Time.now.to_i
      Central.redis.rpush "logs::command::run", id
      options[:trackers].each do |tracker|
        Central.redis.lpush tracker, id
      end
      Central.redis.set "logs::#{id}", { :id => id, :status => status.to_i, :error => error, :command => command, :started => started, :finished => finished }.to_json
      # TODO: I've removed trimming since this is just metadata right now... Need to figure out trimming of the actual logs
      #       maybe this should be a function of an admin portal of some kind
      #Central.redis.ltrim "logs::command::run", 0, 1000
      if DEBUG
        puts command
        puts status.to_i
        puts stdout
        puts stderr if stderr
      end
    end

    def self.after_batch_actions(id, command, options = {})
      # Do something interesting
    end
  end
end
