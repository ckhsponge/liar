require 'user'
require 'game'
require 'clooneys_resource'
class Ai
  def self.go
    puts 'go'
    unless ( user = User.me )
      puts "user not found"
      user = User.new_me
      if user.save
        puts "success: #{user.id}"
      else
        puts "fail: #{user.errors.inspect}"
        return
      end
    end
    puts user.inspect
    games = Game.all
    game = games.first
    puts "FIRST game: #{game.inspect}"
    raise "missing game id" unless game.id
    game.join( user )
  end
end
Ai.go
