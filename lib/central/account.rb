class Central
	class Account
		attr_reader :id, :props, :clusters, :key

		def initialize(id)
			@id = id
			@key = "accounts"
			@props = Central.redis.hgetall "accounts::#{@id}" || {}
		end

		def save(props={})
			props_v = props.reject {|k,v| not ["name"].include? k} 
			Central.redis.sadd "accounts", @id
			Central.redis.hmset "accounts::#{@id}", "name", props_v[:name]
		end

		def add_env(e_id,c_id)
			@id = e_id
			Central.redis.sadd "accounts::#{@id}::environments", c_id
		end

		def delete_env(c_id)
			Central.redis.srem "accounts::#{@id}::environments", c_id
		end

		def self.environments(id)
			@id = id
			@a_id = Central.redis.smembers("accounts::#{@id}::environments")
			@environments = Central.redis.hgetall "environments::#{@a_id}"
			@environments
		end

		def self.env_list_all(id)
			@id = id
			envs = []
			Central.redis.smembers("accounts::#{@id}::environments").each do |e|
				env = Central.redis.hgetall "environments::#{e}"
				envs << env
			end
			envs
		end
		
		def self.list_all
			envs = []
			Central.redis.smembers("accounts").each do |id|
				envs << Account.new(id)
			end
			envs
		end
	end
end