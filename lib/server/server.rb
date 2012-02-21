class Central
  class Server
    module Deploy
      def perform(args*)
        started = Time.now.to_i
        sleep 1
        error = nil

        Central.debug "Creating Nagios server: #{@name}"

        begin
          status = spawn @deploy_command, 'stdout' => stdout, 'stderr' => stderr
        rescue  => e
          error = e
        end

        finished = Time.now.to_i

        Central.redis.lpush "logs::cluster::run", object_id
        Central.redis.set "logs::#{self.object_id}", { :id => object_id, 
                                                     :status => status.to_i, 
                                                     :error => error, 
                                                     :command => @deploy_command, 
                                                     :started => started, 
                                                     :finished => finished}.to_json

        if DEBUG
          puts command
          puts status.to_i
          puts stdout
          puts stderr if stderr
        end

      end

      def after_batch_actions(*args)
        # Do something interesting
      end
    end
  end
end