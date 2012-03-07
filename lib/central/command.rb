class Central
  class Command
    attr_reader :id, :props

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "commands::#{@id}" || {}
      self
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| not ["name", "command"].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "commands", @id
      Central.redis.hmset "commands::#{@id}", "name", props_v[:name], "command", props_v[:command]
      self
    end

    ## class methods
    def self.list_all
      commands = []
      Central.redis.smembers("commands").each do |c_id|
        commands << Command.new(c_id)
      end
      commands
    end

    def self.list(ids)
      commands = []
      ids.each do |c_id|
        commands << Command.new(c_id)
      end
      commands
    end

    class ResultBuffer
      def initialize
        @buffer = []
      end

      def << entry
        @buffer << entry.strip!
      end

      def flush
        @buffer
      end

      def empty?
        @buffer.empty?
      end

      def to_s
        @buffer.join "\n"
      end
    end
    
    class Result
      require 'json'
      attr_accessor :stdout, :stderr, :exit_status, :exception,
                    :timestamp_start, :timestamp_complete,
                    :object_key, :object_id

      def to_s
        h = {}
        h["object_key"] = @key
        h["object_id"] = @object_id
        h["exit_status"] = @exit_status 
        h["exception"] = @exception if @exception
        h["timestamp_start"] = @timestamp_start
        h["timestamp_complete"] = @timestamp_complete
        h["stdout"] = @stdout if @stdout
        h["stderr"] = @stderr if @stderr
        JSON.generate h
      end
    end

  end
end