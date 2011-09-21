require 'clooneys_resource'
class Player < ClooneysResource
  attr_accessor :game

  def collection_path(options = nil)
    raise "no game" unless @game
    raise "no game id" unless @game.id
    "/games/#{@game.id}/#{self.class.collection_name}.xml"
   end

end
