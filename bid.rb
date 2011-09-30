require 'clooneys_resource'
require 'player'
require 'game'
require 'roll'
class Bid < ClooneysResource
  attr_accessor :game
  
  def collection_path(options = nil)
    raise "no game" unless @game
    raise "no game id" unless @game.id
    "/games/#{@game.id}/#{self.class.collection_name}.json"
  end

  def element_path(options = nil)
    raise "no game" unless @game
    raise "no game id" unless @game.id
    "/games/#{@game.id}/#{self.class.collection_name}/#{self.id}.json"
  end

  def to_s
    "#{self.count} #{self.die}s"
  end
end
