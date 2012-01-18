# An app for being happy
# @author Nat Welch - https://github.com/icco

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')
  DB.sql_log_level = :debug

  # Mail Settings
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }

  # for enabling nice errors until we launch
  set :show_exceptions, true
end

# Rack Middleware for Authentication
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :twitter,  ENV['TWITTER_KEY'],  ENV['TWITTER_SECRET']
end

get '/' do
  erb :index
end

get '/list' do
  erb :list, :locals => { :entries => Entry.all }
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

  erb :day, :locals => {
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

  erb :month, :locals => {
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
  less :"css/style"
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
  def html
    markdown = RDiscount.new(
      self.text,
      :smart,
      :filter_html
    )

    return markdown.to_html
  end

  def self.send_reminder
    month = Time.now.month
    day   = Time.now.day
    year  = Time.now.year

    entry_count = Entry.filter(
      'create_date >= ? and create_date < ?',
      Chronic.parse("#{month}/#{day}/#{year}"),
      Chronic.parse("#{month}/#{day+1}/#{year}")
    ).count

    if entry_count < 1
      Pony.mail(
        :from => 'server@happynat.com',
        :to => 'nat@natwelch.com',
        :html_body => erb :mail
      )
    end
  end
end

# Nice time printing
class Time
  def humanize
    if Time.now.strftime("%F") == self.strftime("%F")
      return self.strftime("%l:%M %P")
    elsif Time.now.year == self.year
      return self.strftime("%l%P, %b %e")
    else
      return self.strftime("%b %e '%y")
    end
  end
end
