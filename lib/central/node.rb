class Central
  class Node
    attr_reader :id, :props, :cluster, :key, :commands

    def initialize(id)
      @id = id
      @key = "nodes"
      @props = Central.redis.hgetall "nodes::#{id}" || {}
    end

    def save(n_id, zone_id, ip, name, role)
      @id = n_id
      Central.redis.sadd "nodes", @id
      Central.redis.set "nodes::#{name}", @id
      Central.redis.hmset "nodes::#{@id}", "id", @id, "name", name, "ip", ip, "zone_id", zone_id, "role", role
    end

    def self.deploy(ip, node_id, node_name)
      puts @id
      puts node_id
      Resque.enqueue(Deploy, @key, @id, ip, node_id, node_name)
    end

    def cluster
      @cluster ||= Cluster.new(nodes["cluster_id"])
    end

    def self.info(id)
      @id = id
      info = Central.redis.hgetall "nodes::#{id}" || {}
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

    def add_node(props, id, ver, erlang_cookie)
      puts props
      props_v = props.reject {|k,v| not ["zone_id", "name", "version", "role"]}
      @z = erlang_cookie
      @ver = ver
      case props_v["role"]
        when "opensips", "whapps", "rabbitmq"
          run_list = "role[winkstart_deploy_haproxy]", "role[winkstart_deploy_whapps]", "recipe[apache2::winkstart]", "recipe[winkstart]", "role[winkstart_deploy_opensips]"
        when "freeswitch"
          run_list = "role[winkstart_deploy_whistle_fs]"
        when "bigcouch"
          run_list = "role[winkstart_deploy_bigcouch]"
      end
      test = {
        "name" => props_v["name"],
        "version" => @ver,
        "erlang_cookie" => @z,
        "run_list" => run_list
      }
      url = "http://hudson.2600hz.org/v2.5.0.json"
      resp = Net::HTTP.get_response(URI.parse(url))
      buffer = resp.body
      result = JSON.parse(buffer)
      merge_test = result.merge(test)
      File.open("/tmp/#{id}-#{props_v["name"]}.json", "w") do |f|
        f.write(JSON.pretty_generate(merge_test))
      end
    end

    def add_zone_node(id, name, role, ver, erlang_cookie)
      @z = erlang_cookie
      @ver = ver
      case role
        when "opensips", "whapps", "rabbitmq"
          run_list = "role[winkstart_deploy_haproxy]", "role[winkstart_deploy_whapps]", "recipe[apache2::winkstart]", "recipe[winkstart]", "role[winkstart_deploy_opensips]"
        when "freeswitch"
          run_list = "role[winkstart_deploy_whistle_fs]"
        when "bigcouch"
          run_list = "role[winkstart_deploy_bigcouch]"
      end
      test = {
        "name" => name,
        "version" => @ver,
        "erlang_cookie" => @z,
        "run_list" => run_list
      }
      url = "http://hudson.2600hz.org/v2.5.0.json"
      resp = Net::HTTP.get_response(URI.parse(url))
      buffer = resp.body
      result = JSON.parse(buffer)
      merge_test = result.merge(test)
      File.open("/tmp/#{id}-#{name}.json", "w") do |f|
        f.write(JSON.pretty_generate(merge_test))
      end
    end

    def test(props, ver, z)
      puts props
      puts props["name"]
      props_v = props.reject {|k,v| not ["zone_id", "name", "version"]}
      puts props_v["version"]
      puts props_v["name"]
      @z = z
      @ver = ver
      puts @ver
      puts @z
      test = {
        "name" => props_v["name"],
        "version" => @ver,
        "erlang_cookie" => @z,
        "client_id" => "foo2"
      }
      url = "http://hudson.2600hz.org/v2.5.0.json"
      resp = Net::HTTP.get_response(URI.parse(url))
      buffer = resp.body
      result = JSON.parse(buffer)
      merge_test = test.merge(result)
      File.open("/tmp/#{props_v["name"]}", "w") do |f|
        f.write(JSON.pretty_generate(merge_test))
      end
    end
  end
end