require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

configure do
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym
  p RACK_ENV
  connections = {
    :development => "postgres://localhost/happynat",
    :test => "postgres://postgres@localhost/happynat_test",
    :production => ENV['DATABASE_URL']
  }
  p connections

  url = URI(connections[RACK_ENV])
  options = {
    :adapter => url.scheme,
    :host => url.host,
    :port => url.port,
    :database => url.path[1..-1],
    :username => url.user,
    :password => url.password
  }

  case url.scheme
  when "sqlite"
    options[:adapter] = "sqlite3"
    options[:database] = url.host + url.path
  when "postgres"
    options[:adapter] = "postgresql"
  end
  set :database, options

  use Rack::Session::Cookie, :key => 'rack.session',
    :path => '/',
    :expire_after => 86400, # 1 day
    :secret => ENV['SESSION_SECRET'] || '*&(^B234'

  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_SID']
    config.auth_token = ENV['TWILIO_TOKEN']
  end
end

get "/" do
  erb :index
end

post "/sms" do
  #@client = Twilio::REST::Client.new
  p params
  response = Twilio::TwiML::Response.new do |r|
    r.Message 'hello there'
  end
end

error 400..510 do
  @code = response.status
  erb :error
end
