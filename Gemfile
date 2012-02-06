source :rubygems

# Server requirements (defaults to WEBrick)
gem 'thin'
gem 'rack', "~> 1.4.1"

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
gem 'padrino', '= 0.10.5'

# For URLPARSER
gem "ruby-oembed", :require => 'oembed'
gem "httparty"

# Database
group :production do
  gem "pg"
end

# For dev.
group :development, :test do
  gem "heroku"
  gem "shotgun"
  gem "sqlite3"

  # Until Taps Fixes dependency issues, just gem install.
  #gem "taps", :git => 'git://github.com/ricardochimal/taps.git'
end
