class Central
  class Node
    attr_reader :id, :props

    def initialize(id)
      @id = id
      @object = "node"
      @props = Central.redis.hgetall "nodes::#{@id}" || {}
      self
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| not ["name", "cluster", "command_id"].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "nodes", @id
      Central.redis.hmset "nodes::#{@id}", "name", props_v[:name], "cluster", props_v[:cluster]
      Resque.enqueue(Deploy, @object, @id, props_v[:command_id])
    end


    ## class methods
    def self.list_all
      nodes = []
      Central.redis.smembers("nodes").each do |n_id|
        nodes << Node.new(n_id)
      end
      nodes
    end

    def self.list(ids)
      nodes = []
      ids.each do |n_id|
        nodes << Node.new(n_id)
      end
      nodes
    end
  end
end