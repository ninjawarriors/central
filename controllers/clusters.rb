# TODO: Do we still need this?
# TODO: Env, Cl, and Nodes are all intertwined, need to come up with a better organizaiton
class Central

  get '/clusters' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Clusters", request.path_info)
    @keys = redis.smembers("clusters")
    haml :clusters
  end

  get '/clusters/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Clusters", request.path_info)
    @active = Central.crumb("Create")
    @environments = redis.smembers "environments"
    haml :clusters_create
  end

  post '/clusters' do
    id = counter
    @environment = params[:environment]
    @cluster_name = params[:name]
    redis.sadd "environments::#{@environment}::clusters", @cluster_name
    command = "knife client list | grep test"
    Resque.enqueue(ClusterNameserver, Central.counter, command )
    redirect to('/')
  end

end