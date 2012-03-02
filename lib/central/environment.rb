class Central
  class Environment
    attr_accessor :id, :props, :clusters

    def initialize(id)
      @id = id
      @props = Central.redis.hgetall "environments::#{@id}" || {}
      @clusters = Central.redis.smembers "environments::#{@id}::clusters" || []
    end

    def save(props={})
      props_v = props.reject {|k,v| [:name].include? k} ## quick validation to remove extra POSTed elements
      Central.redis.sadd "environments", @id
      Central.redis.hmset "environments::#{@id}", "name", props_v[:name]
    end

    def add_cluster(c_id)
      Central.redis.sadd "environments::#{@id}::clusters", c_id
      @clusters << c_id
    end

    def delete_cluster(c_id)
      Central.redis.srem "environments::#{@id}::clusters", c_id
      @clusters.delete(c_id)
    end

    ## class methods
    def self.list
      envs = {}
      Central.redis.smembers("environments").each do |id|
        envs[id] = Environment.new(id)
      end
      envs
    end

  end
end