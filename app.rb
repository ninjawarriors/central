require 'rubygems'
require 'sinatra/base'
require 'redis'
require 'haml'
require 'systemu'

DEBUG = true

$redis = Redis.new

class Central < Sinatra::Base
  def self.debug msg
    puts "d-_-b #{msg}" if DEBUG
  end

  def self.redis
    $redis
  end
  
  get '/' do
    haml :index
  end
  
  get '/clusters' do
    @keys = redis.smembers("server_groups")
    haml :clusters
  end
  
  get "/nodes" do
    haml :nodes
  end

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
    erb :node   
  end

  get '/command' do
    @title = 'Run Command'
    @history = $redis.lrange "logs::command::run", 0, -1
    haml :command
  end
  post '/command' do
    id = counter
    Resque.enqueue(CommandRun, id, params[:command])
    redirect to('/command')
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
    redis.sadd "server_groups", @cluster_name
    Resque.enqueue(ClusterCreate, params[:name])
    redirect to('/')
  end
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end
