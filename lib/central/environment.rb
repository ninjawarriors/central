class Central
  class Environment
    attr_reader :id, :props, :clusters

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "environments::#{@id}" || {}
      @clusters = load_clusters
      self
    end

    def save(props={})
      props_v = props.reject {|k,v| not ["name"].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "environments", @id
      Central.redis.hmset "environments::#{@id}", "name", props_v[:name]
      self
    end

    def add_cluster(c_id)
      Central.redis.sadd "environments::#{@id}::clusters", c_id
      load_clusters
    end


    def delete_cluster(c_id)
      Central.redis.srem "environments::#{@id}::clusters", c_id
      load_clusters
    end

    ## class methods
    def self.list_all
      envs = []
      Central.redis.smembers("environments").each do |id|
        envs << Environment.new(id)
      end
      envs
    end

    private
    def load_clusters
      puts "loading clusters for #{@props["name"]}"
      Cluster.list( Central.redis.smembers("environments::#{@id}::clusters") ) || []
    end
  end
end