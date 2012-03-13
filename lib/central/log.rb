class Central
  class Log
    attr_reader :props
    
    def initialize object_id
      @object_id = object_id
      json = Central.redis.get "logs::#{@object_id}" 
      json = "{}" if json.nil?
      @props = JSON.parse(json)
    end

    def save data
      Central.redis.set "logs::#{@object_id}", data.to_json
    end
    
    def stdout start_line=0, end_line=-1
      @stdout ||= tail "stdout", start_line, end_line 
    end

    def stderr start_line=0, end_line=-1
      @stderr ||= tail "stderr", start_line ,end_line
    end

    def tail stream, start_line, end_line
      Central.redis.lrange "logs::#{@object_id}::#{stream}", start_line, end_line
    end

    class Buffer
      def initialize object_id, stream
        @buffer = []
        @object_id = object_id
        @stream = stream
      end

      def << entry
        @buffer << entry.strip!
        Central.redis.rpush "logs::#{@object_id}::#{@stream}", entry
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
  end
end