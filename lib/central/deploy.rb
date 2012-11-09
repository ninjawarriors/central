class Central
  class Deploy
    @queue = "server_deployment"

    def self.perform(object, object_id, ip)
      Central.debug "Bootstrapping Node #{ip}"

      install_epel(ip)
      install_curl(ip)
    end

    def self.queue(debug, cmd, ip)
      Central.debug debug
      command = "ssh -p 22 root@#{ip} '#{cmd}'"
      log = Log.new object_id
      b_stdout = Log::Buffer.new object_id, "stdout"
      b_stderr = Log::Buffer.new object_id, "stderr"

      h = {}
      h["exit_status"] = 1
      h["started"] = Time.now.to_f
      h["finished"] = nil
      log.save h

      begin
        status = spawn command, 'stdout' => b_stdout, 'stderr' => b_stderr
      rescue => e
        h["error"] = e
      end
      h["finished"] = Time.now.to_f
      log.save h

      if DEBUG
        puts command
        puts status.to_i
        puts b_stdout
        puts b_stderr if b_stderr
      end
    end

    def self.install_curl(ip)
      debug = "Installing curl on Node #{ip}"
      cmd = "yum install -y curl"
      ip = ip
      queue(debug, cmd, ip)
    end

    def self.install_epel(ip)
      debug = "Installing Epel on Node #{ip}"
      cmd = "rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm"
      ip = ip
      queue(debug, cmd, ip)
    end


    def self.perform_old(object, object_id, command_id)
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