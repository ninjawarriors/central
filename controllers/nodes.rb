class Central
  get "/nodes" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Nodes", "/nodes")
    @nodes = Node.list_all
    haml "nodes/list"
  end

  get "/nodes/create" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Nodes", "/nodes")
    @active = Central.crumb("Create")
    @zones = Zone.list_all
    @commands = Command.list_all
    haml "nodes/create"
  end

  get '/nodes/:node' do |n_id|
    pass if n_id == "create"
    @node = Node.info(n_id)
    @z_version = Central.redis.get "zones::#{@node["zone_id"]}::version"
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb( "Nodes", "/nodes")
    @active = Central.crumb(@node["name"] + " node", request.path_info)
    @logs = Log.new n_id
    haml "nodes/show"
  end
  
  post '/nodes' do
    id = counter
    n = Node.new(id)
    n.save(params)
    d = Node.deploy(params["ip"])
    z = Zone.new(params["zone_id"])
    z.add_node(n.id)
    redirect to('/nodes')
  end

  post '/node_upgrade' do
    id = counter
    node_id = params["node_id"]
    zone_id = params["zone_id"]
    @z = Zone.info(zone_id)
    n = Node.new(id)
    n.test(params, @z["erlang_cookie"])
    redirect to("/nodes/#{node_id}")
  end
end