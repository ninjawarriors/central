class Central
  module ServerCreate
    @queue = :server

    def self.perform(name, options = {})
      sleep 1
      Central.debug "Creating Server: #{name}"
    end

    def self.after_batch_actions(name, options = {})
      # Do something interesting
    end
  end
end
