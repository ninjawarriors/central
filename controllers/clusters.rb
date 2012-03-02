# TODO: Do we still need this?
# TODO: Env, Cl, and Nodes are all intertwined, need to come up with a better organizaiton
class Central

  get '/clusters' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Clusters", request.path_info)
    @clusters = Cluster.list
    haml :clusters
  end

  get '/clusters/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Clusters", request.path_info)
    @active = Central.crumb("Create")
    @environments = Environment.list
    haml :clusters_create
  end

  post '/clusters' do
    id = counter
    c = Cluster.new(id).save(params)
    Environment.new(params[:environment]).add_cluster(c.id)
    redirect to('/')
  end

end