class Central

  get "/nodes" do
    @nodes = Node.list_all
    haml :nodes
  end

  get "/nodes/create" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Nodes", request.path_info)
    @active = Central.crumb("Create")
    @clusters = Cluster.list_all
    @commands = Command.list_all
    haml :node_create
  end

  post '/nodes' do
    id = counter
    n = Node.new(id).save(params)
    Cluster.new(params["cluster"]).add_node(id)
    redirect to('/nodes')
  end

end