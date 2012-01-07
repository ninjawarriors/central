# = Gemfile containing requirements for this app =
#     see http://gembundler.com/ for more on how to use this file

# = source (there are others but whatever)
source :rubygems

# = All =
gem "rack"                      # the base of the base
gem "sinatra"                   # the base of our web app
gem "rack-flash"                # enables flash[:notice] && flash[:error]
gem "thin"                      # thin server

gem "redis"
gem "resque"
gem "json"
gem "SystemTimer"
gem "systemu"
gem "resque-batched-job"

group :production do
  gem 'pony'
end

group :development do
  gem "foreman"                 # To support Procfile during development
  gem "rake"
  gem 'compass'
end
