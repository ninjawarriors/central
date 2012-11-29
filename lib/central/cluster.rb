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

    def add_zone(c_id,z_id)
      @id = c_id
      Central.redis.sadd "clusters::#{@id}::zones", z_id
    end
        
    def delete_zone(c_id,z_id)
      @id = c_id
      Central.redis.srem "clusters::#{@id}::zones", z_id
    end
    
    def zones
      @zones ||= Zone.list( Central.redis.smembers("clusters::#{@id}::zones"))
    end

    def env
      @env ||= Environment.new(@props["environment_id"])
    end

    def self.upgrade(version, cluster_id)
      cluster_zones = Central.redis.smembers "clusters::#{cluster_id}::zones"
      Central.redis.set "clusters::#{cluster_id}::version", version
      cluster_zones.each do |zone_id|
        nodes = Central.redis.smembers "zones::#{zone_id}::nodes"
        nodes.each do |node|
          ip = Central.redis.hget "nodes::#{node}", "ip"
          Resque.enqueue(Upgrade, ip, version)
        end
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