require 'rubygems'
#require 'activesupport'
require 'active_resource'
require 'uri'
class Clooneys::Resource < ActiveResource::Base
  LOGIN = "liar5"
  EMAIL_ADDRESS = 'liar5@toonsy.net'
  PASSWORD = 'pass5'
  self.site = "http://localhost:3000"
  self.user = LOGIN
  self.password = PASSWORD

  def self.find_from_site( type, site, path )
    #uri = URI.parse( url )
    #site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    #path = uri.path
    puts "site: #{site} path: #{path}"
    #klass = class_for_site(site)
    #object = klass.find(:one, :from => path)
    original_site = self.site
    self.site = site
    object = self.find( :one, :from => path)
    self.site = original_site
    return object
  end

  def self.find_from_long_poll( type, site, path)
    while true
      begin
        puts "Polling"
        result = find_from_site( type, site, path )
        return result
      rescue MultiJson::DecodeError
      end
    end
  end

  #def self.class_for_site( site )
  #  puts "#{self.to_s}"
  #  @@class_hash ||= {}
  #  @@class_hash[self.to_s] ||= {}
  #  @@class_hash[self.to_s][site] ||= Class.new(ActiveResource::Base) do
  #    self.site = site
  #  end
  #  return @@class_hash[self.to_s][site]
  #end
  #
  #def get(path, headers = {})
  #  with_auth { request(:get, path, build_request_headers(headers, :get, self.site.merge(path))) }
  #end
end
