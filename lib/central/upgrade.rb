class Central
	module Upgrade
		@queue = "upgrade"

		def self.perform(ip, version)
			Central.debug "Upgrading Cluster Node #{ip} to version #{version}"
			h = {}
			h['started'] = Time.now.to_f
			log = Log.new object_id
			b_stdout = Log::Buffer.new object_id, "stdout"
      b_stderr = Log::Buffer.new object_id, "stderr"
			command = "ssh -p 22223 #{ip} 'cat /etc/issue'"

			begin
				status = spawn command, 'stdout' => b_stdout, 'stderr' => b_stderr
			rescue => e
				h["error"] = e
			end
			h['finished'] = Time.now.to_f
			log.save h


			if DEBUG
        puts command
        puts status.to_i
        puts b_stdout
        puts b_stderr if b_stderr
      end
		end

	end
end