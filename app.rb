require 'rubygems'
require 'sinatra/base'
require 'redis'

class Central < Sinatra::Base
  def self.debug msg
    puts "d-b #{msg}"
  end

  get '/' do
    @title = 'CENTRAL'
    @server_job_counter = redis.get("server_job_counter")
    @cluster_job_counter = redis.get("cluster_job_counter")
    erb :index
  end

  post '/servers' do
    id = redis.incr("server_job_counter")
    Resque.enqueue(ServerCreate, params[:name])
    redirect to('/')
  end
  
  post '/clusters' do
    id = redis.incr("cluster_job_counter")
    Resque.enqueue(ClusterCreate, params[:name])
    redirect to('/')
  end
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end
