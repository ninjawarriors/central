class Central
  class Node
    attr_reader :id, :props, :cluster, :key, :commands

    def initialize(id)
      @id = id
      @key = "nodes"
      @props = Central.redis.hgetall "nodes::#{@id}" || {}
    end

    def save(props={})
      props_v = props.reject {|k,v| not ["name", "cluster_id", "command_id"].include? k}

      Central.redis.sadd "nodes", @id
      Central.redis.hmset "nodes::#{@id}", "name", props_v[:name], "cluster_id", props_v[:cluster_id], "command_id", props_v[:command_id]
      Central.redis.set "nodes::#{props_v[:name]}", @id

      Resque.enqueue(Deploy, @key, @id, props_v[:command_id])
    end

    def cluster
      @cluster ||= Cluster.new(@props["cluster_id"])
    end

    def commands
      @commands ||= Central.redis.lrange("nodes::#{@id}::command_results", 0, -1).map! {|c| JSON.parse c}
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