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
    
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Clusters", "/clusters")
    @active = Central.crumb(@cluster.props["name"], request.path_info)
    haml "clusters/show"
  end

  post '/clusters' do
    id = counter

    c = Cluster.new(id)
    c.save(params)

    e = Environment.new(params["environment"])
    e.add_cluster(c.id)

    redirect to('/clusters')
  end

end