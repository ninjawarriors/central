class Central

  get "/environments" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Environments", request.path_info)
    @environments = Environment.list
    haml :environments
  end

  get '/environments/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb(" Environment", request.path_info)
    haml :environment_create
  end

  get '/environments/:environment' do |environment|
    pass unless environment != 'create'
    e = Environment.load
    @environment = environment
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb(environment.capitalize + " Environment", request.path_info)
    @clusters = redis.smembers "environments::#{environment}::clusters"
    @env_name = JSON.parse(redis.get("environments::#{environment}"))["name"]
    haml :environment
  end
  
  get '/environments/:environment/:cluster' do |environment,cluster|
    @environment = environment
    @cluster_id = cluster
    @cluster_name = JSON.parse(redis.get("clusters::#{cluster}"))["name"]
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb(environment.capitalize + " Environment", "/environments/#{environment}")
    @active = Central.crumb(cluster.capitalize + " Cluster", request.path_info)
    @nodes = redis.smembers "clusters::#{@cluster_id}::nodes"
    haml :cluster
  end

  get '/environments/:environment/:cluster/:node' do |environment,cluster,node|
    @environment = environment
    @cluster = cluster
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb(environment.capitalize + " Environment", "/environments/#{environment}")
    @crumbs << Central.crumb(cluster.capitalize + " Cluster", "/environments/#{environment}/#{cluster}")
    @active = Central.crumb(node + " Node", request.path_info)
    @node = redis.get "nodes::#{node}"
    haml :node
  end

  post '/environments' do
    id = counter ## this can lead to confusion
    Environment.new(id).save({"name" => params[:name]})
    redirect to('/')
  end

end