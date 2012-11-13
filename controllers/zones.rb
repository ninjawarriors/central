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
    @z_id = id
    @z_version = Central.redis.get "zones::#{id}::version"
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

  post '/zone_deploys' do
    n = Zone.upgrade(params["version"],params["zone_id"])
    zone_id = params["zone_id"]
    redirect to("/zones/#{zone_id}")
  end
end