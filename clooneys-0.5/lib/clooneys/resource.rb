require 'rubygems'
#require 'activesupport'
require 'active_resource'
require 'uri'
class Clooneys::Resource < ActiveResource::Base
  LOGIN = "liar5"
  EMAIL_ADDRESS = 'liar5@toonsy.net'
  PASSWORD = 'pass5'
  @@short_host = "clooneys.net"
  @@long_poll_host = "noodle.clooneys.net"
  self.site = "http://#{@@short_host}"
  self.user = LOGIN
  self.password = PASSWORD

  class << self
    def short_host= host
      self.site = "http://#{host}"
      @short_host = host
    end

    def short_host
      @short_host
    end

    def long_poll_host= host
      @@long_poll_host = host
    end

    def long_poll_host
      @@long_poll_host
    end

    def find_from_site( type, site, path )
      #uri = URI.parse( url )
      #site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      #path = uri.path
      puts "site: #{site} path: #{path}"
      #klass = class_for_site(site)
      #object = klass.find(:one, :from => path)
      original_site = self.site
      self.site = site
      object = self.find( :one, :from => path)
      object.connection = nil
      self.site = original_site
      return object
    end

    def find_from_long_poll( type, path)
      while true
        begin
          puts "Polling"
          result = find_from_site( type, "http://#{long_poll_host}", path )
          return result
        rescue MultiJson::DecodeError
        end
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
