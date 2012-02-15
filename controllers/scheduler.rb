class Central

  get '/scheduler' do
    @schedules = Central.scheduler.all
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Scheduler", request.path_info)
    haml :scheduler
  end

  post '/scheduler' do
    Central.scheduler.add_schedule params unless params[:command] == ""
    redirect to('/scheduler')
  end

  delete '/scheduler/:id' do
    Central.scheduler.delete_cron params[:id]
    redirect to('/scheduler')
  end

end