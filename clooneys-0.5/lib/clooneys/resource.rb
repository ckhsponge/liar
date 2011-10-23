require 'rubygems'
#require 'activesupport'
require 'active_resource'
require 'uri'
class Clooneys::Resource < ActiveResource::Base
  LOGIN = "liar5"
  EMAIL_ADDRESS = 'liar5@toonsy.net'
  PASSWORD = 'pass5'
  #@@short_host = "clooneys.net"
  #@@long_poll_host = "noodle.clooneys.net"
  #self.site = "http://#{@@short_host}"
  self.user = LOGIN
  self.password = PASSWORD

  class << self
    #def short_host= host
    #  @short_host = host
    #  self.site = short_site
    #end
    #
    #def short_host
    #  @short_host
    #end
    #
    #def short_site
    #  "http://#{@short_host}"
    #end
    #
    #def long_poll_host= host
    #  @@long_poll_host = host
    #end
    #
    #def long_poll_host
    #  @@long_poll_host
    #end
    #
    #def find_from_site( type, site, path )
    #  #uri = URI.parse( url )
    #  #site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    #  #path = uri.path
    #  puts "setting site: #{site} path: #{path}"
    #  #klass = class_for_site(site)
    #  #object = klass.find(:one, :from => path)
    #  original_site = self.site
    #  self.site = site
    #  object = nil
    #  begin
    #    object = self.find( type, :from => path)
    #  ensure
    #    object.connection = nil if object
    #    puts "resetting site to: #{original_site}"
    #    self.site = original_site
    #  end
    #  return object
    #end

    def find_from_long_poll( type, path, options = {} )
      start_time = Time.now
      while true
        begin
          puts "Polling"
          #result = find_from_site( type, "http://#{long_poll_host}", path )
          params = {}
          #params[:site] = options[:site] if options[:site]
          result = find( type, :from => path, :site => options[:site] )
          return result
        rescue MultiJson::DecodeError
        end
        return nil if options[:wait] && Time.now - start_time > options[:wait]
      end
    end
  end

  def next_version( options = {} )
    version = options[:version] ? options[:version].to_i : nil
    version ||= self.lock_version.to_i + 1 if self.respond_to? :lock_version
    suffix = version ? "?version=#{version}" : ""
    #return self.class.find_from_long_poll( :one, "#{element_path.sub(/\..*$/,'')}#{suffix}", options)
    raise "long_poll_url not defined" unless self.respond_to? :long_poll_url
    uri = URI.parse( self.long_poll_url )
    site = "#{uri.scheme}://#{uri.host}"
    site += ":#{uri.port}" if uri.port
    puts "SITE: #{site}"
    #return self.class.find_from_long_poll( :one, uri.path, :site => uri )
    return self.class.find_from_long_poll( :one, self.long_poll_url, options )
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


module ActiveResource
  # Class to handle connections to remote web services.
  # This class is used by ActiveResource::Base to interface with REST
  # services.
  class Connection


    private
      # Makes a request to the remote service.
      def request(method, path, *arguments)
        puts "REQUEST #{path}"
        uri = URI.parse( path )
        request_http = http
        if uri.host
          path = uri.path
          request_http = Net::HTTP.new(uri.host, uri.port) #ignores @timeout and @proxy
        else
          uri = site
        end
        puts "URI #{uri.inspect}"
        result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
          payload[:method]      = method
          payload[:request_uri] = "#{uri.scheme}://#{uri.host}:#{uri.port}#{path}"
          payload[:result]      = request_http.send(method, path, *arguments)
        end
        handle_response(result)
      rescue Timeout::Error => e
        raise TimeoutError.new(e.message)
      rescue OpenSSL::SSL::SSLError => e
        raise SSLError.new(e.message)
      end
  end
end