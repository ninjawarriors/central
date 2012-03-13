class Central
  class Deploy
    @queue = "server_deployment"

    def self.perform(object, object_id, command_id)
      puts "Running command ##{command_id} to #{object}::#{object_id}"

      command = Command.new command_id
      log = Log.new object_id
      b_stdout = Log::Buffer.new object_id, "stdout"
      b_stderr = Log::Buffer.new object_id, "stderr"

      h = {}
      h["exit_status"] = 1
      h["started"] = Time.now.to_f
      h["finished"] = nil
      log.save h

      begin
        h["command"] = command.props["command"]
        h["exit_status"] = spawn command.props["command"],'stdout' => b_stdout,'stderr' => b_stderr
      rescue => e
        h["error"] = e.strip!
      end

      h["finished"] = Time.now.to_f
      log.save h
    end
  end
end