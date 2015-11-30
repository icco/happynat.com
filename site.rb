require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

configure do
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym
  connections = {
    :development => "postgres://localhost/happynat",
    :test => "postgres://postgres@localhost/happynat_test",
    :production => ENV['DATABASE_URL']
  }

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
  # {
  #   "ToCountry"=>"US",
  #   "ToState"=>"NY",
  #   "SmsMessageSid"=>"SM7b7271dd550ee8340eb40ef296325ce7",
  #   "NumMedia"=>"0",
  #   "ToCity"=>"",
  #   "FromZip"=>"95403",
  #   "SmsSid"=>"SM7b7271dd550ee8340eb40ef296325ce7",
  #   "FromState"=>"CA",
  #   "SmsStatus"=>"received",
  #   "FromCity"=>"SANTA ROSA",
  #   "Body"=>"test",
  #   "FromCountry"=>"US",
  #   "To"=>"+16468762600",
  #   "MessagingServiceSid"=>"MGec57cdb198f67ca5720b77bc2b395c56",
  #   "ToZip"=>"",
  #   "NumSegments"=>"1",
  #   "MessageSid"=>"SM7b7271dd550ee8340eb40ef296325ce7",
  #   "AccountSid"=>"ACd13bade3c51c7c83670737a310dc790a",
  #   "From"=>"+17077998675",
  #   "ApiVersion"=>"2010-04-01"
  # }
  response = Twilio::TwiML::Response.new do |r|
    r.Message 'hello there'
  end
end

error 400..510 do
  @code = response.status
  erb :error
end
