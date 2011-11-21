require 'rubygems'
require 'sinatra'
require 'sass'
require 'json'
require 'redis'

class Central < Sinatra::Base
  
      set :root, File.dirname(__FILE__)
    set :static, true
    set :public_folder, Proc.new { File.join(root, "public") }
    
  def self.debug msg
    puts "d-b #{msg}"
  end

    before do
      content_type 'application/json'
    end

    get '/' do
      content_type 'text/html'
            @js = erb :event_templates, :layout => false
      body erb :index
    end
  
  get '/css/sonian.css' do
      content_type 'text/css'
      body sass :sonian
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
