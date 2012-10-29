class Central
  class Cluster
    attr_reader :id, :props, :nodes, :env, :key

    def initialize(id)
      @id = id
      @key = "clusters"
      @props = Central.redis.hgetall "clusters::#{@id}" || {}
    end

    def save(props={})
      props_v = props.reject {|k,v| not ["name", "environment_id", "command_id"].include? k}

      Central.redis.sadd "clusters", @id
      Central.redis.hmset "clusters::#{@id}", "name", props_v[:name], "environment_id", props_v[:environment_id]
    end

    def add_node(n_id)
      Central.redis.sadd "clusters::#{@id}::nodes", n_id
    end
        
    def delete_node(n_id)
      Central.redis.srem "clusters::#{@id}::nodes", n_id
    end
    
    def nodes
      @nodes ||= Node.list( Central.redis.smembers("clusters::#{@id}::nodes"))
    end

    def env
      @env ||= Environment.new(@props["environment_id"])
    end

    def self.upgrade(version, cluster_id)
      cluster_nodes = Central.redis.smembers "clusters::#{cluster_id}::nodes"
      Central.redis.set "clusters::#{cluster_id}::version", version
      cluster_nodes.each do |node_id|
        node = Central.redis.hgetall "nodes::#{node_id}"
        ipa = Central.redis.hget "nodes::#{node_id}", "ip"
        puts ipa
        Resque.enqueue(Upgrade, ipa, version)
      end
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

  end
end