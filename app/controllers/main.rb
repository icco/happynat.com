HappyNat.controller do
  layout :main

  get '/' do
    render :index
  end

  get '/list' do
    render :list, :locals => { :entries => Entry.order(:create_date.desc).all }
  end

  post '/' do
    if !session["username"].nil?
      entry = Entry.new
      entry.create_date = Time.now
      entry.username = session["username"]
      entry.text = params["text"]
      entry.save
    end

    redirect '/'
  end

  # For getting a period of time.
  get %r{/date/(\d{4})/(\d{1,2})/(\d{1,2})/?} do
    day =   params[:captures][2].to_i
    month = params[:captures][1].to_i
    year =  params[:captures][0].to_i

    render :day, :locals => {
      :entries => Entry.filter(
        'create_date >= ? and create_date < ?',
        Chronic.parse("#{month}/#{day}/#{year}"),
        Chronic.parse("#{month}/#{day+1}/#{year}")
    ).all,
      :date => Chronic.parse("#{day}/#{month}/#{year}")
    }
  end

  get %r{/date/(\d{4})/(\d{1,2})/?} do
    day = 1
    month = params[:captures][1].to_i
    year =  params[:captures][0].to_i

    render :month, :locals => {
      :entries => Entry.filter(
        'create_date >= ? and create_date < ?',
        Chronic.parse("#{month}/#{day}/#{year}"),
        Chronic.parse("#{month+1}/#{day}/#{year}")
    ).all,
      :date => Chronic.parse("#{month}/#{day}/#{year}")
    }
  end

  get %r{/date/(\d{4})/?} do
    day = 1
    month = 1
    year = params[:captures][0].to_i

    render :year, :locals => {
      :entries => Entry.filter(
        'create_date >= ? and create_date < ?',
        Chronic.parse("#{day}/#{month}/#{year}"),
        Chronic.parse("#{day}/#{month}/#{year+1}")
    ).all,
      :date => Chronic.parse("#{day}/#{month}/#{year}")
    }
  end

  # For getting a single post
  get '/view/:id' do
    if params[:id].to_i
      Entry.filter(:id => params[:id]).first.to_s
    else
      404
    end
  end

  # Auth Lambda.
  auth = lambda do
    auth = request.env['omniauth.auth']

    # TODO: Log the auth information somewhere!
    #p auth["info"]

    session['username'] = auth["info"].nickname
    redirect '/'
  end

  # Actual auth endpoints.
  post '/auth/:name/callback', &auth
  get  '/auth/:name/callback', &auth
end
