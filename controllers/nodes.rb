class Central

  get "/nodes" do
    @nodes = Node.list
    haml :nodes
  end

  get "/nodes/create" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Nodes", request.path_info)
    @active = Central.crumb("Create")
    @clusters = Cluster.list
    haml :node_create
  end

  # TODO: Why not nodes?
  get '/servers/*' do
    @keys = params[:splat].first.split('/')
    @servers = case redis.type(@keys)
    when "string"
      Array(redis[@keys])
    when "list"
      redis.lrange(@keys, 0, -1)
    when "set"
      redis.smembers(@keys)
    else
      []
    end
    @foo = Array.new
    @servers.each do |s|
      @foo << redis.hgetall(s)
    end

    haml :servers
  end

  get '/nodes/*' do
    @keys = params[:splat].first.split('/')
    @node = case redis.type(@keys)
    when "string"
      Array(redis[@keys])
    when "hash"
      redis.hgetall(@keys)
    when "list"
      redis.lrange(@keys, 0, -1)
    when "set"
      redis.smembers(@keys)
    else
      []
    end
    haml :node
  end

  post '/nodes' do
    id = counter
    n = Node.new(id).save(params)
    Cluster.new(params[:cluster]).add_node(n.id)
    #Resque.enqueue(ServerCreate, params[:name], @env)
    redirect to('/')
  end

end