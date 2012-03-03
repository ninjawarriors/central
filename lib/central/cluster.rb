class Central
  class Cluster
    attr_reader :id, :props, :nodes

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "clusters::#{@id}" || {}
      @nodes = load_nodes
      self
    end

    ## add validation here, because each POST prop will be saved otherwise
    def save(props={})
      props_v = props.reject {|k,v| not ["name", "environment", "command"].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "clusters", @id
      Central.redis.hmset "clusters::#{@id}", "name", props_v[:name], "environment", props_v[:environment]
      self
    end

    def add_node(n_id)
      Central.redis.sadd "clusters::#{@id}::nodes", n_id
      load_nodes
    end
        
    def delete_node(n_id)
      Central.redis.srem "clusters::#{@id}::nodes", n_id
      load_nodes
    end

    ## class methods
    def self.list_all
      clusters = []
      Central.redis.smembers("clusters").each do |c_id|
        clusters << Cluster.new(c_id)
      end
      clusters
    end

    def self.list(cluster_ids)
      clusters = []
      cluster_ids.each do |id|
        clusters << Cluster.new(id)
      end
      clusters
    end

    ## flat list of all nodes for every cluster_id
    def self.list_nodes(cluster_ids)
      nodes = []
      cluster_ids.each do |id|
        nodes.concat Cluster.new(id).nodes
      end
      nodes
    end

    private 
    def load_nodes
      puts "loading nodes for #{@props["name"]}"
      Node.list( Central.redis.smembers("clusters::#{@id}::nodes") ) || []
    end
  end
end