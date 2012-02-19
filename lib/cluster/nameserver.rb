require 'json'

class RedisTailer
  def initialize id, type
    @id = id
    @type = type
    @entries = []
    @buffer = ""
  end

  def << entry
    entry.strip!
    puts "LOGGING: #{entry}" if DEBUG
    @entries << entry
    Central.redis.rpush "logs::#{@id}::#{@type}", entry
  end

  def to_s
    @entries.join "\n"
  end
end

class Central
	module ClusterNameserver
		@queue = :cluster 

		def self.perform(id, command, options = {})
			started = Time.now.to_i
      Central.debug "TEST TEST: #{id} --- #{command}"
			sleep 1
			error = nil
			stdout = RedisTailer.new id, "stdout"
			stderr = RedisTailer.new id, "stderr"
			Central.debug "Creating Name Server: #{name}"
      begin
        status = spawn command, 'stdout' => stdout, 'stderr' => stderr
      rescue => e
        error = e
      end
			finished = Time.now.to_i
			Central.redis.lpush "logs::cluster::run", id
      Central.redis.set "logs::#{id}", { :id => id, :status => status.to_i, :error => error, :started => started, :finished => finished }.to_json
      if debug
        puts command
      	puts status.to_i
      	puts stdout
      	puts stderr if stderr
      end
		end

		def on_failure_retry(error, *args)
			Resque.enqueue self, *args
		end
	end
end