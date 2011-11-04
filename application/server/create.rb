module ServerCreate
  @queue = :server

  def self.perform(name, options = {})
    debug "Creating Server: #{name}"
  end

  def self.after_batch_actions(name, options = {})
    # Do something interesting
  end
end
