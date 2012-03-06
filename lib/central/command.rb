class Central
  class Command
    attr_reader :id, :props

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "commands::#{@id}" || {}
      self
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| not ["name", "command"].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "commands", @id
      Central.redis.hmset "commands::#{@id}", "name", props_v[:name], "command", props_v[:command]
      self
    end

    ## class methods
    def self.list_all
      commands = []
      Central.redis.smembers("commands").each do |c_id|
        commands << Command.new(c_id)
      end
      commands
    end

    def self.list(ids)
      commands = []
      ids.each do |c_id|
        commands << Command.new(c_id)
      end
      commands
    end
  end
end