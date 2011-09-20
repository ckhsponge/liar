require 'rubygems'
#require 'activesupport'
require 'active_resource'
class ClooneysResource < ActiveResource::Base
  LOGIN = "liar2"
  EMAIL_ADDRESS = 'liar2@toonsy.net'
  PASSWORD = 'pass2'
  self.site = "http://localhost:3000"
  self.user = LOGIN
  self.password = PASSWORD
end
