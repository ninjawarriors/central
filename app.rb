require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'redis'
require 'resque'
require 'haml'
require 'open4'
include Open4

DEBUG = true

$redis = Redis.new
Resque.redis = $redis

class NilClass
  def method_missing(*args, &block)
    nil
  end
end

class Central < Sinatra::Base

  def initialize
    super
    # read the config file
    @config = File.exists?("config/config.yml") ? YAML.load_file("config/config.yml") : {}
  end

  set :method_override, true
  def self.debug msg
    puts "d-_-b #{msg}" if DEBUG
  end

  def self.redis; $redis; end
  def self.counter; redis.incr "global_counter"; end

  def self.scheduler
    @scheduler = Scheduler.instance
  end
  
  get '/' do
    @keys = redis.smembers("clusters")
    haml :index
  end
  
  get '/clusters' do
    @keys = redis.smembers("clusters")
    haml :clusters
  end
  
  get "/nodes" do
    haml :nodes
  end

  get "/environments" do
    @keys = redis.smembers("environments")
    haml :environments
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

  get '/command' do
    @title = 'Run Command'
    @commands = {}
    @ids = $redis.lrange("logs::command::run", 0, -1).reverse
    @ids.each do |id|
      @commands[id] = JSON.parse $redis.get "logs::#{id}"
    end
    haml 'command/index'
  end
  post '/command' do
    Central.scheduler.add_schedule params
    redirect to('/command')
  end
  get '/command/:id' do
    @id = params[:id]
    @details = JSON.parse $redis.get "logs::#{@id}"
    @logs = {}
    @logs[:stdout] = $redis.lrange "logs::#{@id}::stdout", 0, -1
    @logs[:stderr] = $redis.lrange "logs::#{@id}::stderr", 0, -1
    haml 'command/details'
  end
  get '/command/:id/tail/:stream' do
    id = params[:id]
    stream do |out|
      out << "<pre>"
      out << "Tailing #{params[:stream]} for id #{params[:id]}\n\n"
      init = $redis.lrange("logs::#{params[:id]}::#{params[:stream]}", 0, -1)
      size = init.length
      Central.debug "#{id}----Size >> #{size}"
      out << init.join("\n")
      out << "\n"

      while true
        n = $redis.lrange("logs::#{params[:id]}::#{params[:stream]}", size, -1)
        if n.length > 0
          size += n.length
          Central.debug "#{id}----Size >> #{size}"
          out << n.join("\n")
          out << "\n"
        end
        sleep 1
      end
    end
  end

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
  
  post '/clusters' do
    id = counter
    @cluster_name = params[:name]
    redis.sadd "clusters", @cluster_name
    command = "knife client list | grep test"
    Resque.enqueue(CommandRun, Central.counter, command, {:trackers => ["command::DeployCluster"]})
    redirect to('/')
  end

  post '/environments' do
    id = counter
    @env_name = params[:name]
    redis.sadd "environments", @env_name
    redirect to('/')
  end
end

# Since we don't want resque workers running the scheduler, we check for
# QUEUE in the environment, which means it's a worker looking at a queue
# TODO: Split the workers out better so we don't have to load the entire
# stack every time
require './lib/scheduler'

require './lib/libraries'
