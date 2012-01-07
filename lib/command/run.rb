class Central
  module CommandRun
    @queue = :cms

    def self.perform(id, command, options = {})
      Central.debug "Running Arbitrary Command: #{command}"
      status, stdout, stderr = systemu command
      Central.redis.lpush "logs::command::run", { :id => id, :status => status.to_i, :command => command, :output => stdout, :stderr => stderr }.to_json
      Central.redis.ltrim "logs::command::run", 0, 1000
      if DEBUG
        puts command
        puts status.to_i
        puts stdout
        puts stderr if stderr
      end
    end

    def self.after_batch_actions(id, command, options = {})
      # Do something interesting
    end
  end
end
