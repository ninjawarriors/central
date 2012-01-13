class RedisTailer
  def initialize id, type
    @id = id
    @type = type
    @entries = []
    @buffer = ""
  end

  def << entry
    @buffer << entry
    lines = @buffer.split("\n")
    @buffer = lines.last
    lines.delete lines.last
    @entries.concat lines

    lines.each do |line|
      Central.redis.rpush "logs::#{@id}::#{@type}", line
    end
  end

  def flush
    if @buffer and @buffer != ""
      lines = @buffer.split("\n")
      @entries.concat lines

      lines.each do |line|
        Central.redis.rpush "logs::#{@id}::#{@type}", line
      end
    end
  end

  def to_s
    @entries.join("\n")
  end
end

class Central
  module CommandRun
    @queue = :cms

    def self.perform(id, command, options = {})
      started = Time.now.to_i
      Central.debug "Running Arbitrary Command: #{command}"
      stdout = RedisTailer.new id, "stdout"
      stderr = RedisTailer.new id, "stderr"
      status = systemu command, 'stdout' => stdout, 'stderr' => stderr
      stdout.flush
      stderr.flush
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
