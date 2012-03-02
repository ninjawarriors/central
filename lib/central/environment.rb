class Central
  class Environment
    attr_accessor :id, :name, :clusters

    def initialize(id)
      @id = id
    end

    def save(args={})
      Central.redis.sadd "environments", @id
      Central.redis.set "environments::#{@id}", {"name" => args[:name]}.to_json
    end

    def clusters
        @clusters = redis.smembers "environments::#{@id}::clusters" || []
    end

    def clusters=(*clusters_id)
        clusters_id.each do |c_id|
          redis.sadd "environments::#{@id}::clusters", c_id
        end
        get_clusters
    end

    ## class methods
    def self.load(id)
      e = Environment.new(id)
      o = JSON.parse(Central.redis.get "environments::#{id}")
      e.name = o["name"]
    end

    def self.list
      Central.redis.smembers "environments"
    end

  end
end