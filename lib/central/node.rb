class Central
  class Node
    attr_accessor :id, :props

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "nodes::#{@id}" || {}
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| [:name, :cluster, :command].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "nodes", @id
      Central.redis.hmset "nodes::#{@id}", "name", props_v[:name], "cluster", props_v[:cluster]
    end

    ## class methods
    def self.list
      nodes = {}
      Central.redis.smembers("nodes").each do |n_id|
        nodes[n_id] = Node.new(n_id)
      end
      nodes
    end

  end
end