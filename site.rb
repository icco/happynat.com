# An app for being happy
# @author Nat Welch - https://github.com/icco

configure do
  set :sessions, true
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')

  # for enabling nice errors until we launch
  set :show_exceptions, true
end

# Rack Middleware for Authentication
use OmniAuth::Builder do
  provider :twitter,  ENV['TWITTER_KEY'],  ENV['TWITTER_SECRET']
end

get '/' do
  erb :index, :locals => { :entries => Entry.all }
end

post '/' do
  redirect '/'
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  less :style
end

# Auth Lambda.
auth = lambda do
  auth = request.env['omniauth.auth']

  # TODO: Log the auth information somewhere!
  p auth
end

# Actual auth endpoints.
post '/auth/twitter/callback', &auth
get  '/auth/twitter/callback', &auth

get '/:id' do
  Entry.filter(:id => params[:id]).first.to_s
end

class Entry < Sequel::Model(:entries)
end
