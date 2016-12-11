require 'rubygems'
#require 'activesupport'
require 'active_resource'
require 'uri'
class Clooneys::Resource < ActiveResource::Base
  self.site = "http://www.clooneys.net"
  @@long_poll_host = "http://noodle.clooneys.net"

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
    def long_poll_host= host
      @@long_poll_host = host
    end

    def long_poll_host
      @@long_poll_host
    end
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
          puts "Polling (#{Time.now - start_time})"
          result = find( type, options.merge(:from => path) )
          return result
        rescue MultiJson::DecodeError
        end
        if options[:wait] && Time.now - start_time > options[:wait]
          puts "wait exceeded, ending poll"
          return nil
        end
      end
    end
  end

  #gets the most recent version from the long poll server
  def reload_from_long_poll( options = {} )
    raise "long_poll_url not defined" unless self.respond_to? :long_poll_url
    return self.class.find_from_long_poll( :one, self.long_poll_url, options.merge(:params => {:version => 0}) )
  end

  #waits for the next version from the long poll server
  def next_version( options = {} )
    version = options[:version] ? options[:version].to_i : nil
    version ||= self.lock_version.to_i + 1 if self.known_attributes.include?( "lock_version" )
    puts "NEXT VERSION: #{version}"
    suffix = version ? "?version=#{version}" : ""
    #return self.class.find_from_long_poll( :one, "#{element_path.sub(/\..*$/,'')}#{suffix}", options)
    raise "long_poll_url not defined" unless self.respond_to? :long_poll_url

    return self.class.find_from_long_poll( :one, self.long_poll_url, options.merge(:params => {:version => version}) )
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
        puts "REQUEST #{path} #{arguments.inspect}"
        uri = URI.parse( path )
        request_http = http
        if uri.host
          path = uri.request_uri #includes params unlike path()
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
