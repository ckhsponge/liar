require 'clooneys/resource'
class Clooneys::Bid < Clooneys::Resource
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
  
  def next
    return nil if self.die == 6 && self.count >= @game.dice_count
    bid = Clooneys::Bid.new
    bid.die = ( self.die % 6) + 1 #increment die
    bid.count = self.die == 6 ? self.count + 1 : self.count
    bid.die = 2 if @game.bid && @game.aces_wild && bid.die == 1
    bid.game = @game
    return bid
  end

  def odds( user )
    return @odds if @odds
    @odds = @game.odds_for_user( self, user )
    return @odds
  end

  def to_s
    "#{self.count} #{self.die}s"
  end
end
