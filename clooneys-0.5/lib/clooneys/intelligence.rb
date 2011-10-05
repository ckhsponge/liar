class Clooneys::Intelligence

  def initialize( game, user)
    @game = game
    @user = user
    Clooneys::Exception.new( "No game" ) unless @game
    Clooneys::Exception.new( "No user" ) unless @user
  end

  def wait_for_update
    url = @game.long_poll_url
    #url = "/games/#{@game.id}"
    game = Clooneys::Game.find_from_long_poll( :one, "http://localhost:8000", "/games/#{@game.id}?version=#{@game.lock_version + 1}" )
    puts game.attributes.inspect
    @game = game if game
    puts "Found game wait_for_update: #{game.inspect}"

    #c = Clooneys::Game.print_info( "http://localhost:8000" )
    #puts "#{c.name} #{c.site.inspect}"
  end

  def start
    while !@game.complete?
      known_dice = @game.dice_for_user( @user )
      puts "My dice: #{known_dice.join(",")}"
      if @game.can_bid?( @user )
        make_bid
        sleep 2
        @game = Clooneys::Game.find_from_site( :one, "http://localhost:3000", "/games/#{@game.id}" )
      end
      wait_for_update unless @game.can_bid?( @user ) || @game.complete?
    end
  end

  def make_bid
    bullshit_odds = 0.0
    if @game.bid
      r = rand
      bullshit_odds = @game.bid.odds( @user )
      selected = r <= (1.0 - @game.bid.odds( @user ))**4
      puts "#{@game.bid} bullshit odds: #{@game.bid.odds( @user )} - #{r} - #{selected}"
      if selected
        @game.make_bid_bullshit( @user )
        return
      end
    end
    bids = next_bids
    bids.each do |bid|
      puts "#{bid} odds: #{bid.odds( @user )}"
    end
    puts "Trying"
    selected_bid = nil
    bids.shuffle.each do |bid|
      r = rand
      selected = r <= (bid.odds( @user )**2)
      puts "#{bid} odds: #{bid.odds( @user )} - #{r} - #{selected}"
      if selected
        selected_bid = bid
        break
      end
    end
    if !selected_bid && bullshit_odds > 0.99999
      selected_bid = bids.sort{ |a,b| a.odds(@user) <=> b.odds(@user)}.last
      puts "No bid found, choosing best one: #{selected_bid}"
    end
    if selected_bid
      puts "BIDDING: #{selected_bid}"
      @game.make_bid( @user, selected_bid.count, selected_bid.die)
    else
      puts "BULLSHIT"
      @game.make_bid_bullshit( @user )
    end
  end

  def next_bids
    bid = @game.bid ? @game.bid.next : Clooneys::Bid.new( :count => 1, :die => 1)
    return [] unless bid
    bid.game = @game
    bids = [bid]
    1.upto(12) do
      bid = bids.last.next
      break unless bid
      bids << bid
    end
    return bids
  end
end
