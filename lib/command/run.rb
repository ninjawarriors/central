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
  module CommandRun
    @queue = :cms

    def self.perform(id, command, options = {})
      started = Time.now.to_i
      Central.debug "Running Arbitrary Command ID: #{id} --- #{command}"
      stdout = RedisTailer.new id, "stdout"
      stderr = RedisTailer.new id, "stderr"
      #status = systemu command, 'stdout' => stdout, 'stderr' => stderr
      begin
        status = spawn command, 'stdout' => stdout, 'stderr' => stderr
      rescue Open4::SpawnError
      end
      finished = Time.now.to_i
      Central.redis.lpush "logs::command::run", { :id => id, :status => status.to_i, :command => command, :started => started, :finished => finished }.to_json
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
