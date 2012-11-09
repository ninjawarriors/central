class Central
  get "/zones" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Zones", "/zones")
    @zones = Zone.list_all
    haml "zones/list"
  end

  get '/zones/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/zones")
    @active = Central.crumb("Create", request.path_info)
    @clusters = Cluster.list_all
    haml "zones/create"
  end

  get '/zones/:id' do |id|
    pass if id == "create"
    @zone = Zone.new(id)
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/zones")
    @active = Central.crumb(@environment.props["name"], request.path_info)
    haml "zones/show"
  end

  post '/zones' do
    id = counter
    z = Zone.new(id)
    z.save(params)
    c = Cluster.new(params["cluster_id"])
    c.add_zone(params["cluster_id"], id)
    redirect to('/zones')
  end

  post '/deploys' do
    n = Cluster.upgrade(params["version"],params["cluster_id"])
    cluster_id = params["cluster_id"]
    redirect to("/clusters/#{cluster_id}")
  end

  get '/example.json' do
    content_type :json
    foo = Central.redis.get "nodes::16"
  end
end