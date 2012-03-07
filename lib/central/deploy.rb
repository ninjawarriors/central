class Central
  class Deploy
    @queue = "server_deployment"
    def self.perform(object, object_id, command_id)
      puts "Running command ##{command_id} to #{object}::#{object_id}"

      command = Command.new(command_id)
      puts "Running '#{command.props["command"]}'"

      b_stdout = Command::ResultBuffer.new
      b_stderr = Command::ResultBuffer.new
      exit_status = -1
      exception = ""
      
      started = Time.now.to_i
      begin
        status = spawn command.props["command"], 'stdout' => b_stdout, 'stderr' => b_stderr
      rescue => e
        exception = e.strip!
      end

      complete = Time.now.to_i
      
      result = Command::Result.new
      result.object_key = object
      result.object_id = object_id
      result.exit_status= exit_status.to_i
      result.timestamp_start = started
      result.timestamp_complete = complete
      result.stdout = b_stdout.flush if not b_stdout.empty? 
      result.stderr = b_stderr.flush if not b_stderr.empty?
      result.exception = exception if not exception.empty?

      #Central.redis.rpush "commands::#{command_id}::results", result.to_s
      Central.redis.rpush "#{object}::#{object_id}::command_results", result.to_s

    end
  end
end