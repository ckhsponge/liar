class Clooneys::Intelligence
  attr_accessor :game, :user

  def initialize( game, user)
    @game = game
    @user = user
    Clooneys::Exception.new( "No game" ) unless @game
    Clooneys::Exception.new( "No user" ) unless @user
  end

  def wait_for_update
    next_game = @game.next_version( :wait => @game.bid_seconds_remaining ? @game.bid_seconds_remaining + 1 : nil)
    if next_game
      @game = next_game
    else
      @game.reload
    end
  end

  def start
    while !@game.complete? && @game.dice_count_for_user( @user ) > 0
      if self.game.can_bid?( @user )
        make_next_bid
        wait_for_update
        sleep 1
        #@game = Clooneys::Game.find_from_short( :one, "/games/#{@game.id}" )
      end
      wait_for_update unless @game.can_bid?( @user ) || @game.complete?
    end
    puts "No dice left" if @game.dice_count_for_user( @user ) == 0
  end

  def make_next_bid
    raise "not allowed to bid" unless self.game.can_bid?( self.user )
    bid = next_bid
    raise "no bid" unless bid
    puts "BIDDING: #{bid}"
    self.game.make_bid( self.user, bid)
  end

  def next_bid
    known_dice = self.game.dice_for_user( self.user )
    puts "My dice: #{known_dice.join(",")}"
    bids = []
    if self.game.bid
      bullshit_bid = self.game.bid.clone
      bullshit_bid.bullshit = true
      bullshit_odds = bullshit_bid.odds( self.user ) ** 3
      bullshit_bid.odds = bullshit_odds
      puts "#{bullshit_bid} bullshit odds: #{bullshit_odds}"
      return bullshit_bid if bullshit_odds > 0.9944 ** 3
      bids << bullshit_bid
    end
    bids += next_bids( 6 )
    bids.each do |bid|
      puts "#{bid} odds: #{bid.odds( self.user )}"
    end
    odds_sum = bids.inject(0) {|s,b| s + b.odds( self.user )}
    puts "Odds sum: #{odds_sum}"
    pick = odds_sum * rand
    puts "Random pick index: #{pick}"
    index = 0.0
    bids.each do |bid|
      index += bid.odds( self.user )
      puts "#{bid} index: #{index}"
      return bid if pick <= index
    end
    puts "WARNING: No bid found picked! Picking last one."
    return bids.last
  end

  def next_bids( limit = nil )
    bid = @game.bid ? @game.bid.next : Clooneys::Bid.new( :count => 1, :die => 1)
    return [] unless bid
    bid.game = @game
    bids = [bid]
    while ( bid = bids.last.next )
      bids << bid
      break if limit && bids.size >= limit
    end
    return bids
  end
end
