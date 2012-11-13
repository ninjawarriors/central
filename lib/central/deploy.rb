class Central
  class Deploy
    @queue = "server_deployment"

    def self.perform(object, object_id, ip, node_id, node_name)
      Central.debug "Bootstrapping Node #{ip}"

      copy_node_json(ip, node_id, node_name)
      install_epel(ip)
      install_curl(ip)
      curl_repo(ip)
      setup_deps(ip)
      env_reset(ip)
      copy_databag(ip)
      chef_solo(ip, node_id, node_name)
    end

    def self.copy_node_json(ip, node_id, node_name)
      debug = "Copying node json file to Node #{ip}"
      command = "scp /tmp/#{node_id}-#{node_name}.json root@#{ip}:/root"
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

    def self.curl_repo(ip)
      debug = "Downloading Chef-Solo files on Node #{ip}"
      cmd ="curl -# -L -k https://gist.github.com/gists/6ca69e9fec594156a846/download | tar xz --strip 1 -C ."
      ip = ip
      queue(debug, cmd, ip)
    end

    def self.setup_deps(ip)
      debug = "Running bootstrap script on Node #{ip}"
      cmd = "bash ~/bootstrap.sh"
      ip = ip
      queue(debug, cmd, ip)
    end

    def self.env_reset(ip)
      debug = "Updating ENV variables on Node #{ip}"
      cmd = "source /etc/profile"
      ip = ip
      queue(debug, cmd, ip)
    end

    def self.copy_databag(ip)
      debug = "Copying files to the correct locations on Node #{ip}"
      cmd = "cp foo1.json /root/data_bags/accounts"
      ip = ip
      queue(debug, cmd, ip)
    end

    def self.chef_solo(ip, node_id, node_name)
      debug = "Running Chef Solo on Node #{ip}"
      cmd = "chef-solo -j #{node_id}-#{node_name}.json -c solo.rb -l debug"
      ip = ip
      queue(debug, cmd, ip)
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