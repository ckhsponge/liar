#!/usr/bin/ruby
require "rubygems"
require "bundler/setup"
require 'clooneys'

#Clooneys::Resource.site = "http://localhost:3000"
#ENV['LONG_POLLL_HOST'] = "localhost:8000"

users = YAML.load( File.read('users.yml') )
puts users.inspect
user_params = users[ARGV[0]]
user_params.each_key {|k| user_params[k.to_s.intern] = user_params[k]} #symbolize hash
raise "No user '#{ARGV[0]}'" unless user_params
puts user_params.inspect
user = Clooneys::User.sign_in( user_params )
raise "Could not sign in" unless user

configs = YAML.load( File.read('config.yml') )
puts configs.inspect
config_params = configs[ARGV[1]]
if config_params
  Clooneys::Resource.site = "http://#{config_params['host']}"
  Clooneys::Resource.long_poll_host = "http://#{config_params['long_poll_host']}"
end

Clooneys::Console.new( user ).start
