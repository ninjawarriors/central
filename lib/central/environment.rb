class Central
  class Environment
    attr_reader :id, :props, :clusters, :key

    def initialize(id)
      @id = id
      @key = "environments"
      @props = Central.redis.hgetall "environments::#{@id}" || {}
    end

    def save(props={})
      props_v = props.reject {|k,v| not ["name", "account_id"].include? k} 

      Central.redis.sadd "environments", @id
      Central.redis.hmset "environments::#{@id}", "name", props_v[:name], "account_id", props_v[:account_id]
    end

    def add_cluster(e_id,c_id)
      @id = e_id
      Central.redis.sadd "environments::#{@id}::clusters", c_id
    end

    def delete_cluster(c_id)
      Central.redis.srem "environments::#{@id}::clusters", c_id
    end

    def clusters
      @clusters ||= Cluster.list(Central.redis.smembers("environments::#{@id}::clusters"))
    end
    
    ## class methods
    def self.list_all
      envs = []
      Central.redis.smembers("environments").each do |id|
        envs << Environment.new(id)
      end
      envs
    end

  end
end