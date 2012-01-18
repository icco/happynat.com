require 'rubygems'
require 'bundler'

Bundler.require

require './site'

require './models'

run Sinatra::Application
