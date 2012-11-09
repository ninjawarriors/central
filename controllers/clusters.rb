class Central
  get '/clusters' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Clusters", "/clusters")
    @clusters = Cluster.list_all
    haml "clusters/list"
  end

  get '/clusters/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Clusters", "/clusters")
    @active = Central.crumb("Create")
    @environments = Environment.list_all
    haml "clusters/create"
  end

  get '/clusters/:cluster' do |c_id|
    pass if c_id == "create"
    @cluster = Cluster.new(c_id)
    @zones = Zone.new(c_id)
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Clusters", "/clusters")
    @active = Central.crumb(@cluster.props["name"], request.path_info)
    @c_version = Central.redis.get "clusters::#{c_id}::version"
    @c_id = c_id
    haml "clusters/show"
  end

  post '/clusters' do
    id = counter
    c = Cluster.new(id)
    c.save(params)
    e = Environment.new(params["environment"])
    e.add_cluster(params["environment_id"],id)
    redirect to('/clusters')
  end

  post '/cluster_deploys' do
    n = Zone.upgrade(params["version"],params["zone_id"])
    zone_id = params["zone_id"]
    redirect to("/zones/#{zone_id}")
  end
end