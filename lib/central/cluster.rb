class Central
  class Cluster
    attr_accessor :id, :props, :nodes

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "clusters::#{@id}" || {}
      @nodes = Central.redis.smembers "clusters::#{@id}::nodes" || []
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| [:name, :environment, :command].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "clusters", @id
      Central.redis.hmset "clusters::#{@id}", "name", props_v[:name], "environment", props_v[:environment]
    end

    def add_node(n_id)
      Central.redis.sadd "clusters::#{@id}::nodes", n_id
      @nodes << n_id
    end
        
    def delete_node(n_id)
      Central.redis.srem "clusters::#{@id}::nodes", n_id
      @nodes.delete(n_id)
    end

    ## class methods
    def self.list
      clusters = {}
      Central.redis.smembers("clusters").each do |c_id|
        clusters[c_id] = Cluster.new(c_id)
      end
      clusters
    end

  end
end