class Central
	module Upgrade
		@queue = "upgrade"

		def self.perform(object, object_id, command_id)
			Central.debug "Upgrading Cluster"
			log = Log.new object_id
			b_stdout = Log::Buffer.new object_id, "stdout"
      b_stderr = Log::Buffer.new object_id, "stderr"
			h['started'] = Time.now.to_f
			h['finished'] = nil
			log.save h

			begin
				h['command'] = command
				h["exit_status"] = spawn command,'stdout' => b_stdout,'stderr' => b_stderr
			rescue => e
				h["error"] = e.strip!
			end
		end

	end
end