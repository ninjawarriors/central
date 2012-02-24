class Central

  get "/nodes" do
    haml :nodes
  end

  get "/nodes/create" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("Nodes", request.path_info)
    @active = Central.crumb("Create")
    haml :nodes
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

  get '/node/*' do
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

  # TODO: Why not nodes?
  post '/servers' do
    id = counter
    @server_name = params[:name]
    @cluster_name = params[:cluster_membership]
    redis.sadd "cluster:#{@cluster_name}", @server_name
    redis.hmset @server_name, "hostname", @server_name, "cluster", @cluster_name
    if @cluster_name == "Ops"
      @env = "ops"
    elsif @cluster_name == "Dev"
      @env = "dev"
    elsif @cluster_name == "QA"
      @env = "qa"
    elsif @cluster_name == "Staging"
      @env = "staging"
    elsif @cluster_name == "Beta"
      @env = "beta"
    elsif @cluster_name == "Prod"
      @env = "prod"
    end
    Resque.enqueue(ServerCreate, params[:name], @env)
    redirect to('/')
  end

end