class Central
	class Deploy
    @queue = "server_deployment"
    def self.perform(object, object_id, command_id)
      puts "Applying command #{command_id} to #{object}::#{object_id}"
      
      command = Command.new(command_id)

      stdout = RedisTailer.new id, "stdout"
      stderr = RedisTailer.new id, "stderr"

      begin
        status = spawn command.props["command"], 'stdout' => stdout, 'stderr' => stderr
      rescue => e
        error = e
        puts e
      end
      puts command.props["command"]
      puts status.to_i
      puts stdout
      puts stderr if stderr
      ## log stuff here for this deployment

    end
	end
end