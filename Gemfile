source :rubygems

gem "less"
gem "rake"
gem "sequel"
gem "sinatra", :git => "git://github.com/sinatra/sinatra.git"
gem "thin"

# For Authentication
gem "omniauth-twitter"  # https://github.com/arunagw/omniauth-twitter
gem "omniauth-facebook" # https://github.com/mkdynamic/omniauth-facebook

# For sending email
gem "pony" # http://devcenter.heroku.com/articles/sendgrid

# For heroku
group :production do
  gem "pg"
end

# For dev.
group :development, :test do
  gem "sqlite3"
  gem "heroku"
end
