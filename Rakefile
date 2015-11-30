require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

require "sinatra/activerecord/rake"
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

namespace :db do
  task :load_config do
    require "./site"
  end
end

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end
