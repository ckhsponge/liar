require 'clooneys_resource'
require 'player'
require 'game'
require 'roll'
class Bid < ClooneysResource

  def to_s
    "#{self.count} #{self.die}s"
  end
end
