require 'clooneys/resource'
class Clooneys::Roll < Clooneys::Resource

  def self.find_rolls( game, round_number)
    find(:all, :from => "/games/#{game.id}/rounds/#{round_number}/rolls.json")
  end
end
