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

    @clusters = Cluster.list_all
    @commands = Command.list_all

    haml "nodes/create"
  end

  get '/nodes/:node' do |n_id|
    pass if n_id == "create"
    @node = Node.new(n_id)

    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb( "Nodes", "/nodes")
    @active = Central.crumb(@node.props["name"] + " node", request.path_info)

    @logs = Log.new n_id
    haml "nodes/show"
  end
  
  post '/nodes' do
    id = counter

    n = Node.new(id)
    n.save(params)

    c = Cluster.new(params["cluster_id"])
    c.add_node(n.id)

    redirect to('/nodes')
  end

end