require 'rubygems'
require 'bundler'

Bundler.require

require 'uri'

require './site'

require './models'

run Sinatra::Application
