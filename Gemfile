source :rubygems

gem "chronic"
gem "json"
gem "less"
gem "rack", "~> 1.4"
gem "rake"
gem "rdiscount"
gem "sequel"
gem "sinatra"

# For Authentication
gem "omniauth", :git => "https://github.com/intridea/omniauth.git"
gem "omniauth-twitter"  # https://github.com/arunagw/omniauth-twitter
gem "multi_json"

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
  gem "shotgun"
end
