require 'clooneys/resource'
class Clooneys::User < Clooneys::Resource
  def self.me
    Clooneys::User.find(:first, :login => LOGIN)
  end

  #must call save to create this
  def self.new_me
    return Clooneys::User.new( :login => LOGIN, :email => EMAIL_ADDRESS, :password => PASSWORD, :password_confirmation => PASSWORD)
  end
end
