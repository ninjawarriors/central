require 'rubygems'
require 'sinatra/base'
require 'redis'
require 'haml'

class Central < Sinatra::Base
  def self.debug msg
    puts "d-b #{msg}"
  end
  
  get '/' do
    @title = 'CENTRAL'
    erb :index
  end
  
  get '/clusters' do
    @keys = redis.keys("server_groups:*")
    haml :servers
  end
  
  get '/servers/*' do
    @keys = params[:splat].first.split('/')
    @data = case redis.type(@keys)
    when "string"
      Array(redis[@keys])
    when "list"
      redis.lrange(@keys, 0, -1)
    when "set"
      redis.smembers(@keys)
    else
      []
    end
    haml :show
  end

  post '/servers' do
    id = counter
    @server_name = params[:name]
    @cluster_name = params[:cluster_membership]
    redis.sadd "cluster:#{@cluster_name}", @server_name
    redis.hmset @server_name, "hostname", @server_name, "cluster", @cluster_name
    Resque.enqueue(ServerCreate, params[:name])
    redirect to('/')
  end
  
  post '/clusters' do
    id = counter
    @cluster_name = params[:name]
    redis.sadd "clusters", @cluster_name
    Resque.enqueue(ClusterCreate, params[:name])
    redirect to('/')
  end
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end
