class Central

  get '/commands' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Commands", request.path_info)
    @title = 'Run Command'
    @commands = {}
    # TODO: Rename this too
    @ids = $redis.lrange("logs::command::run", 0, -1).reverse
    @ids.each do |id|
      @commands[id] = JSON.parse $redis.get "logs::#{id}"
    end
    haml 'commands/index'
  end

  post '/commands' do
    Central.scheduler.add_schedule params
    redirect to('/commands')
  end

  get '/commands/:id' do
    @id = params[:id]
    @details = JSON.parse $redis.get "logs::#{@id}"
    @logs = {}
    @logs[:stdout] = $redis.lrange "logs::#{@id}::stdout", 0, -1
    @logs[:stderr] = $redis.lrange "logs::#{@id}::stderr", 0, -1
    haml 'commands/details'
  end

  # TODO: tidy this up and make it actually work
  get '/commands/:id/tail/:stream' do
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

end