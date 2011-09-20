require 'user'
require 'clooneys_resource'
class Ai
  LOGIN = ClooneysResource::LOGIN
  EMAIL = ClooneysResource::EMAIL_ADDRESS
  PASSWORD = ClooneysResource::PASSWORD
  def self.go
    puts 'go'
    user = User.find(:first, :login => LOGIN)
    puts "after find"
    #users = User.all
    #puts users.inspect
    if user
      puts "user exists"
      puts user.inspect
    else
      puts "user not found"
      user = User.new( :login => LOGIN, :email => EMAIL, :password => PASSWORD, :password_confirmation => PASSWORD)
      if user.save
        puts "success: #{user.id}"
        #puts "exists: #{user.exists?}"
      else
        puts "fail: #{user.errors.inspect}"
      end
    end
  end
end
Ai.go
