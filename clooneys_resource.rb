require 'rubygems'
#require 'activesupport'
require 'active_resource'
class ClooneysResource < ActiveResource::Base
  LOGIN = "liar5"
  EMAIL_ADDRESS = 'liar5@toonsy.net'
  PASSWORD = 'pass5'
  self.site = "http://localhost:3000"
  self.user = LOGIN
  self.password = PASSWORD
end
