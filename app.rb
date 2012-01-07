require 'rubygems'
require 'sinatra/base'
require 'redis'
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
    erb :index
  end

  get '/command' do
    @title = 'Run Command'
    @history = $redis.lrange "logs::command::run", 0, -1
    erb :command
  end
  post '/command' do
    id = counter
    Resque.enqueue(CommandRun, id, params[:command])
    redirect to('/command')
  end

  post '/servers' do
    id = counter
    Resque.enqueue(ServerCreate, params[:name])
    redirect to('/')
  end
  
  post '/clusters' do
    id = counter
    Resque.enqueue(ClusterCreate, params[:name])
    redirect to('/')
  end
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end
