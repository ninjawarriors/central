require 'rubygems'
require 'sinatra'
require 'haml'
require 'redis'

  helpers do
    def redis
      @redis ||= Redis.new
    end
  end
 
  get '/' do
    @title = 'CENTRAL'
    @keys = redis.keys("*")
    haml :index
  end
  
  get '/*' do
    @keys = params[:splat].first
    @data = case redis.type(@key)
    when "string"
      Array(redis[@key])
    when "list"
      redis.lrange(@key, 0, -1)
    when "set"
      redis.set_members(@key)
    else
      []
    end
    haml :show
  end



