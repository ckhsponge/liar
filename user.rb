require 'clooneys_resource'
class User < ClooneysResource
  def self.me
    User.find(:first, :login => LOGIN)
  end

  #must call save to create this
  def self.new_me
    return User.new( :login => LOGIN, :email => EMAIL_ADDRESS, :password => PASSWORD, :password_confirmation => PASSWORD)
  end
end
