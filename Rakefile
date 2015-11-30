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

desc "Send a message."
task :cron => ["db:load_config"] do
  @client = Twilio::REST::Client.new

  @client.account.messages.create({
    :to => '+17077998675',
    :body => 'How are you feeling today?',
  })
end

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end
