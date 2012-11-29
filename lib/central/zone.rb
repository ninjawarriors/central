class Central
	class Zone
		attr_reader :id, :props, :nodes, :env, :key

		def initialize(id)
			@id = id
			@key = "zones"
			@props = Central.redis.hgetall "zones::#{@id}" || {}
		end

		def save(props={})
			props_v = props.reject {|k,v| not ["name", "cluster_id", "command_id", "erlang_cookie", "version"].include? k}

			Central.redis.sadd "zones", @id
			Central.redis.hmset "zones::#{@id}", "name", props_v[:name], "cluster_id", props_v[:cluster_id], "zone_id", @id, "erlang_cookie", props_v[:erlang_cookie], "version", props_v[:version]
		end

		def add_node(n_id)
			Central.redis.sadd "zones::#{@id}::nodes", n_id
		end
				
		def delete_node(n_id)
			Central.redis.srem "zones::#{@id}::nodes", n_id
		end
		
		def nodes
			@nodes ||= Node.list( Central.redis.smembers("zones::#{@id}::nodes"))
		end

		def env
			@env ||= Environment.new(@props["environment_id"])
		end

		def cluster
			@cluster ||= Cluster.new(@props["cluster_id"])
		end

		def self.upgrade(version, zone_id)
			zone_nodes = Central.redis.smembers "zones::#{zone_id}::nodes"  
			Central.redis.set "zones::#{zone_id}::version", version
			@z = Zone.info(zone_id)
			@ver = version
			zone_nodes.each do |node_id|
				node = Central.redis.hgetall "nodes::#{node_id}"
				n = Node.new(node["id"])
				n.test(node, @ver, @z["erlang_cookie"])
				ip = Central.redis.hget "nodes::#{node_id}", "ip"
				Resque.enqueue(Upgrade, ip, version)
			end
		end

		## class methods
		def self.list_all
			zones = []
			Central.redis.smembers("zones").each do |c_id|
				zones << Zone.new(c_id)
			end
			zones
		end

		def self.info(id)
			@id = id
			info = Central.redis.hgetall "zones::#{@id}" || {}
		end

		def self.list(ids)
			zones = []
			ids.each do |z_id|
				zones << Zone.info(z_id)
			end
			zones
		end

		## flat list of all nodes for every zone_id
		def self.list_nodes(zone_ids)
			nodes = []
			zone_ids.each do |id|
				nodes.concat zone.new(id).nodes
			end
			nodes
		end

		def zone_json(props, z_id)
			zone_nodes = Central.redis.smembers "zones::#{z_id}::nodes"
			@fs_list = Array.new
			@whapps_list = Array.new
			@db_list = Array.new
			zone_nodes.each do |node_id|
				node = Central.redis.hgetall "nodes::#{node_id}"
				n = Node.new(node["id"])
				if node["role"] == "freeswitch"
					@fs_list << "\"#{node["name"]}\": \"#{node["ip"]}\""
				elsif node["role"] == "whapps"
					@whapps_list << "\"#{node["name"]}\": \"#{node["ip"]}\""
				elsif node["role"] == "bigcouch"
					@db_list << "\"#{node["name"]}\": \"#{node["ip"]}\""
				end
			end
			@fs_foo = @fs_list.map{|x| x}.join(",")
			@whapps_foo = @whapps_list.map{|x| x}.join(",")
			@db_foo = @db_list.map{|x| x}.join(",")
			File.open("/tmp/zone_#{z_id}_databag.json", "w") do |f|
				f.puts '{
				  "freeswitch": {
				    "servers": {
				      '
				      f.puts @fs_foo
				f.puts'
				    }
				  },
				  "id": "foo1",
				  "whapps": {
				    "servers": {'
				    	f.puts @whapps_foo
				f.puts'      
				    }
				  },
				  "opensips": {
				    "servers": {'
				    	f.puts @whapps_foo
				f.puts'
				    }
				  },
				  "bigcouch": {
				    "servers": {'
				    	f.puts @db_foo
				f.puts'
				    }
				  }
				}'
			end
			zone_nodes.each do |n|
				node = Central.redis.hgetall "nodes::#{n}"
				d = Deploy.copy_zone_databag(node["ip"], z_id)
			end
		end
	end
end