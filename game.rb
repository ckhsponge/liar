require 'clooneys_resource'
require 'player'
class Game < ClooneysResource

  def join(user)
    player = Player.new
    player.game = self
    puts "joining: #{self.id}"
    if player.save
    else
      puts player.errors.inspect
    end
  end
end
