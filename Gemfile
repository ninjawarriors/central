# = Gemfile containing requirements for this app =
#     see http://gembundler.com/ for more on how to use this file

# = source (there are others but whatever)
source :rubygems

# = All =
gem "rack", "1.3.6"             # the base of the base
gem "sinatra"                   # the base of our web app
#gem "rack-flash"                # enables flash[:notice] && flash[:error]
gem "thin"                      # thin server
gem "chef"
gem "net-ssh-multi"
gem "knife-rackspace"
gem "unicorn"                   # unicorn - testing a different server

gem "haml"
gem "redis"
gem "resque"
gem "rufus-scheduler"
gem "json"
gem "SystemTimer", :platforms => :ruby_18 # only install SystemTimer on 1.8.7
gem "open4"
gem "resque-batched-job"

group :production do
  gem 'pony'
end

group :development do
  gem "foreman", "0.36.1"                 # To support Procfile during development
  gem "rake"
  gem 'compass'
end

# Include the base plugins
group :core do
  gem 'central-core'
end

group :noload do
  gem "central-hook-skeleton"
end
