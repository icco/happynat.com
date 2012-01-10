# An app for being happy
# @author Nat Welch - https://github.com/icco

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')
  DB.sql_log_level = :debug

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
get '/date/:year/:month/:day' do
  day = params['day'].to_i
  month = params['month'].to_i
  year = params['year'].to_i

  erb :day, :locals => {
    :entries => Entry.filter(
      'create_date >= ? and create_date < ?',
      Chronic.parse("#{day}/#{month}/#{year}"),
      Chronic.parse("#{day+1}/#{month}/#{year}")
    ).all,
    :date => Chronic.parse("#{day}/#{month}/#{year}")
  }
end

get '/date/:year/:month' do
  day = 1
  month = params['month'].to_i
  year = params['year'].to_i

  erb :month, :locals => {
    :entries => Entry.filter(
      'create_date >= ? and create_date < ?',
      Chronic.parse("#{day}/#{month}/#{year}"),
      Chronic.parse("#{day}/#{month+1}/#{year}")
    ).all,
    :date => Chronic.parse("#{day}/#{month}/#{year}")
  }
end

get '/date/:year' do
  day = 1
  month = 1
  year = params['year'].to_i

  erb :year, :locals => {
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
