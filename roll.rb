require 'clooneys_resource'
require 'player'
require 'game'
class Roll < ClooneysResource

  def self.find_rolls( game, round_number)
    find(:all, :from => "/games/#{game.id}/rounds/#{round_number}/rolls.json")
  end
end
