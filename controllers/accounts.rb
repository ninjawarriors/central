class Central
  get "/accounts" do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("accounts", "/accounts")
    @accounts = Account.list_all
    haml "accounts/list", :layout => :layout2
  end

  get '/accounts/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("account", "/accounts")
    @active = Central.crumb("Create", request.path_info)
    haml "accounts/create", :layout => :layout2
  end

  get '/accounts/:id' do |id|
    pass if id == "create"
    @account = Account.new(id)
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @crumbs << Central.crumb("account", "/accounts")
    @active = Central.crumb(@account.props["name"], request.path_info)
    haml "accounts/show", :layout => :layout2
  end

  post '/accounts' do
    id = counter 
    a = Account.new(id)
    a.save(params)
    redirect to('/accounts')
  end
end