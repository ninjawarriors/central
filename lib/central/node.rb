class Central
  class Node
    attr_reader :id, :props, :cluster, :key, :commands

    def initialize(id)
      @id = id
      @key = "nodes"
      @props = Central.redis.get "nodes::#{@id}" || {}
    end

    def save(props={})
      props_v = props.reject {|k,v| not ["name", "cluster_id", "command_id"].include? k}

      Central.redis.sadd "nodes", @id
      Central.redis.set "nodes::#{props_v[:name]}", @id
      Central.redis.set "nodes::#{@id}", { :id => @id, :name => props_v[:name], :cluster_id => props_v[:cluster_id], :command_id => props_v[:command_id] }.to_json

      Resque.enqueue(Deploy, @key, @id, props_v[:command_id])
    end

    def cluster
      @cluster ||= Cluster.new(nodes["cluster_id"])
    end

    def self.info(id)
      @id = id
      info = JSON.parse(Central.redis.get "nodes::#{@id}") || {}
    end
    
    ## class methods
    def self.list_all
      nodes = []
      Central.redis.smembers("nodes").each do |n_id|
        nodes << Node.info(n_id)
      end
      nodes
    end

    def self.list(ids)
      nodes = []
      ids.each do |n_id|
        nodes << Node.info(n_id)
      end
      nodes
    end

  end
end