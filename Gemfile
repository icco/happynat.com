source :rubygems

# Server requirements (defaults to WEBrick)
gem 'thin'

# Project requirements
gem "chronic"
gem "json"
gem "rdiscount"
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# For Authentication
gem "omniauth", :git => "https://github.com/intridea/omniauth.git"
gem "omniauth-twitter"  # https://github.com/arunagw/omniauth-twitter
gem "multi_json"

# Component requirements
gem 'erubis', "~> 2.7.0"
gem 'rack-less'
gem 'sequel'

# Padrino Stable Gem
gem 'padrino'

# Database
group :production do
  gem "pg"
end

# For dev.
group :development, :test do
  gem "heroku"
  gem "shotgun"
  gem "sqlite3"
end
