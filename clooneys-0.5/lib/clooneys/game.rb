require 'clooneys/resource'
class Clooneys::Game < Clooneys::Resource

  BID_TIME_OPTIONS_HASH = {15.seconds.to_i => "15 Seconds", 1.minutes.to_i => "1 Minute", 5.minutes.to_i => "5 Minutes", 1.hours.to_i => "1 Hours", 4.hours.to_i => "4 Hours" , 1.days.to_i => "1 Day" }
  BID_TIME_OPTIONS = BID_TIME_OPTIONS_HASH.to_a.collect{ |a| a.reverse }

  def self.all( filter = "future" )
    games = self.find(:all, :params => {:filter => filter} )
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

  def print_status( user )
    puts self.name
    puts "Player - Dice Left"
    self.players.each do |player|
      puts "  #{player.login} - #{player.dice_left}"
    end
    if self.round_number
      puts "Total dice left: #{self.dice_count}"
      if self.winner_id
        puts "Winner: #{player_for_user(self.winner_id)}"
      else
        known_dice = self.dice_for_user(user)
        puts "My dice: #{known_dice.join(",")}"
        puts "Bid: #{self.bid}"
        waiter = player_for_user(self.next_bidder_id)
        puts "Waiting for #{ waiter.user_id == user.id ? 'YOU' : waiter}"
      end
    else
      puts "Waiting for game to start"
    end
  end

  def print_odds( bid, user )
    raise "NO BID" unless bid
    puts "Total for #{bid}: #{odds_for_user(bid, user)}"
  end

  def make_bid( user, count, die)
    raise "no user" unless user
    raise "no count" unless count
    raise "no die" unless die
    bid = Clooneys::Bid.new( :game_id => self.id, :count => count, :die => die)
    bid.game = self
    unless bid.save
      raise Clooneys::Exception.new( bid.errors.full_messages.join ',')
    end
  end

  def make_bid_bullshit( user )
    raise "no user" unless user
    bid = Clooneys::Bid.new( :game_id => self.id, :bullshit => true)
    bid.game = self
    unless bid.save
      raise Clooneys::Exception.new( bid.errors.full_messages.join ',')
    end
  end

  def odds_for_user( bid, user )
    known_dice = self.dice_for_user(user)
    return odds(bid, known_dice)
  end

  def odds( bid, known_dice = [] )
    return 0.0 unless bid
    #puts "Calculating odds for #{bid.die}"
    known_match_count = known_dice.reject{ |d| !die_match?(d, bid.die)}.size
    return 1.0 if known_match_count >= bid.count
    sum = 0.0
    for count in (bid.count)..(self.dice_count)
      odds = odds_exact(count, bid.die, known_dice)
      #puts "#{count} #{odds}"
      sum += odds
    end
    return sum
  end

  def odds_exact( count, die, known_dice = [] )
    dice_count = self.dice_count
    return 0.0 if count > dice_count
    known_match_count = known_dice.reject{ |d| !die_match?(d, die)}.size
    return 1.0 if known_match_count >= count
    unknown_count = dice_count - known_dice.size
    #find probability that there are count - known_match_count in the unknown dice
    required_count = count - known_match_count
    return 0.0 if required_count > unknown_count
    #puts "dice unkn req #{dice_count} #{unknown_count} #{required_count}"
    odds_of_match = if self.bid
      self.aces_wild ? (1.0/3.0) : (1.0/6.0)
                    else
      die != 1 ? (1.0/3.0) : (1.0/6.0)
                    end
    return (( odds_of_match )**( required_count )) * (( 1.0 - odds_of_match )**( unknown_count - required_count )) * ( unknown_count.choose(required_count) )
  end

  def die_match?( cup_die, die )
    return true if cup_die == 1 && self.aces_wild
    return cup_die == die
  end

  def dice_count
    self.players.inject(0) {|s, p| p.dice_left + s}
  end

  def dice_for_user( user )
    return [] unless self.round_number
    rolls = rolls_cache( self.round_number )
    rolls.each do |roll|
     return roll.dice if roll.user_id == user.id
    end
    return []
  end

  def rolls_cache( round_number )
    @rolls_cache ||= {}
    @rolls_cache[ round_number.to_s ] ||= Clooneys::Roll.find_rolls( self, round_number )
    return @rolls_cache[ round_number.to_s ]
  end

  def player_for_user ( user )
    return nil unless user
    user_id = user.kind_of?(Fixnum) ? user : user.id
    return nil unless user
    self.players.each do |p|
      return p if p.user_id == user_id
    end
    return nil
  end
  
  def format_bid_time
    s = BID_TIME_OPTIONS_HASH[ self.bid_time.to_i ]
    return s || "#{self.bid_time.to_i} Seconds"
  end

  def to_s
    "#{self.id} - #{self.name} (#{self.format_bid_time}) [#{self.players.collect {|p| p.login}.join(',')}]"
  end
end