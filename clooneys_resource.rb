require 'rubygems'
#require 'activesupport'
require 'active_resource'
class ClooneysResource < ActiveResource::Base
  LOGIN = "liar4"
  EMAIL_ADDRESS = 'liar4@toonsy.net'
  PASSWORD = 'pass4'
  self.site = "http://localhost:3000"
  self.user = LOGIN
  self.password = PASSWORD
end
