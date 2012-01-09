# An app for being happy
# @author Nat Welch - https://github.com/icco

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')

  # for enabling nice errors until we launch
  set :show_exceptions, true
end

# Rack Middleware for Authentication
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :twitter,  ENV['TWITTER_KEY'],  ENV['TWITTER_SECRET']
end

get '/' do
  erb :index, :locals => { :entries => Entry.all }
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
get '/in/:year/:month/:day' do
  day = params['day'].to_i
  month = params['month'].to_i
  year = params['year'].to_i

  erb :day, :locals => {
    :entries => Entry.filter(
      'create_date >= ? and create_date < ?', 
      Chronic.parse("#{day}/#{month}/#{year}"),
      Chronic.parse("#{day+1}/#{month}/#{year}")
    ).all
  }
end

# TODO: add month and year pages

# For getting a single post
get '/view/:id' do
  if params[:id].to_i
    Entry.filter(:id => params[:id]).first.to_s
  else
    404
  end
end

get '/css/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  less "css/style"
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

error 400...510 do
  "Sorry there was a nasty error."
end

class Entry < Sequel::Model(:entries)
end

# Nice time printing
class Time
  def humanize
    if Time.now.strftime("%F") == self.strftime("%F")
      return self.strftime("%l:%M %P")
    elsif Time.now.year == self.year
      return self.strftime("%b %e")
    else
      return self.strftime("%b %e '%y")
    end
  end
end
