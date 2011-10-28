require 'clooneys/resource'
class Clooneys::User < Clooneys::Resource
  def self.me
    raise "login not set" unless self.user
    Clooneys::User.find(:first, :login =>  self.user)
  end

  #must call save to create this
  def self.new_me( email_address )
    return Clooneys::User.new( :login => self.user, :email => email_address, :password => self.password, :password_confirmation => self.password)
  end

  def self.sign_in( options )
    raise "no login" unless options[:login]
    raise "no password" unless options[:password]
    Clooneys::Resource.user = options[:login]
    Clooneys::Resource.password = options[:password]
    unless ( user = Clooneys::User.me )
      puts "user not found"
      user = Clooneys::User.new_me( options[:email_address] )
      if user.save
        puts "Created a new user: #{user.login}"
      else
        raise Clooneys::Exception.new("Failed to create a new user, maybe you forgot your password: #{user.errors.inspect}")
      end
    end
    puts "Signed in #{user.login}"
    return user
  end
end
