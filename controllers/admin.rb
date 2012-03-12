class Central

  get '/admin' do
    @crumbs = []
    @active = Central.crumb("Admin", request.path_info)

    @hooks = Central.hooks
    haml 'admin/index'
  end

  post '/admin/hooks' do
    if params[:action] == "Enable"
      Central.hooks.enable params[:type].to_sym, Kernel.const_get(params[:mod])
    else
      Central.hooks.disable params[:type].to_sym, Kernel.const_get(params[:mod])
    end

    redirect to("/admin")
  end

end
