class Central

  get "/environments" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Environments", "/environments")

    @environments = Environment.list_all
    haml "environments/list"
  end

  get '/environments/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/environments")
    @active = Central.crumb("Create", request.path_info)
    haml "environments/create"
  end

  get '/environments/:id' do |id|
    pass if id == "create"
    @environment = Environment.new(id)
    
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/environments")
    @active = Central.crumb(@environment.props["name"], request.path_info)
    haml "environments/show"
  end

  post '/environments' do
    id = counter 
    
    e = Environment.new(id)
    e.save(params)

    redirect to('/environments')
  end

end