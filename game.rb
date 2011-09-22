
require 'clooneys_resource'
require 'player'
class Game < ClooneysResource

  BID_TIME_OPTIONS_HASH = {15.seconds.to_i => "15 Seconds", 1.minutes.to_i => "1 Minute", 5.minutes.to_i => "5 Minutes", 1.hours.to_i => "1 Hours", 4.hours.to_i => "4 Hours" , 1.days.to_i => "1 Day" }
  BID_TIME_OPTIONS = BID_TIME_OPTIONS_HASH.to_a.collect{ |a| a.reverse }

  def self.all
    games = self.find(:all)
    games.each do |game|
      game.players.each {|p| p.game = game}
    end
    return games
  end

  def join(user)
    player = Player.new
    player.game = self
    puts "joining: #{self.id}"
    if player.save
    else
      puts player.errors.inspect
    end
    return player
  end

  def unjoin( user )
    raise "user not in game" unless (player = player_for_user(user))
    player.destroy
  end

  def player_for_user ( user )
    return nil unless user
    self.players.each do |p|
      return p if p.user_id == user.id
    end
    return nil
  end
  
  def format_bid_time
    s = BID_TIME_OPTIONS_HASH[ self.bid_time.to_i ]
    return s || "#{t.to_i} Seconds"
  end

  def to_s
    "#{self.id} - #{self.name} (#{self.format_bid_time}) [#{self.players.collect {|p| p.login}.join(',')}]"
  end
end
