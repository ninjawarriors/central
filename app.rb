require 'sinatra/base'

class Central < Sinatra::Base
  def self.debug msg
    puts "d-b #{msg}"
  end

  get '/' do
    @title = 'CENTRAL'
    
    erb :index
  end

  post '/servers' do
    Resque.enqueue(ServerCreate, params[:name])
    redirect to('/')
  end
  
  post '/clusters' do
    Resque.enqueue(ClusterCreate, params[:name])
    redirect to('/')
  end
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end
