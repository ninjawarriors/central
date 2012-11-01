class Central

  get "/zones" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("zones", "/zones")

    @zones = Environment.list_all
    haml "zones/list"
  end

  get '/zones/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/zones")
    @active = Central.crumb("Create", request.path_info)
    haml "zones/create"
  end

  get '/zones/:id' do |id|
    pass if id == "create"
    @environment = Environment.new(id)
    
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Environment", "/zones")
    @active = Central.crumb(@environment.props["name"], request.path_info)
    haml "zones/show"
  end

  post '/zones' do
    id = counter 
    
    e = Environment.new(id)
    e.save(params)

    redirect to('/zones')
  end

end