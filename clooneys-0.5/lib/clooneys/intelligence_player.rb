class Clooneys::IntelligencePlayer

  def initialize( klass, user )
    @klass = klass
    raise "no klass" unless @klass
    @user = user
    raise "no user" unless @user
  end

  def start
    while true

      played_present_game = play_present_game
      next if played_present_game

      unless @user.skip_create
        played_created_game = play_created_game
        next if played_created_game
      end
      
      play_other_game unless @user.skip_join
    end
  end

  def play_present_game
    find_my_game( Clooneys::Game::PRESENT, :user => @user ) do |game|
      if game.dice_count_for_user( @user ) > 0
        play_game( game )
        return true
      end
    end
    return false
  end

  def play_created_game
    my_future_game = find_my_game( Clooneys::Game::FUTURE, :creator => @user )
    unless( my_future_game )
      puts "Creating a game"
      my_future_game = Clooneys::Game.new( :bid_time => 60 )
      my_future_game.save!
      puts "my_future_game #{my_future_game.inspect}"
      my_future_game = Clooneys::Game.find( my_future_game.id ) unless my_future_game.respond_to? :next_bidder_id #incomplete response from heroku so reload
    end
    if my_future_game.started?
      puts "Playing started future game"
      play_game( my_future_game )
      return true
    else
      puts "Waiting for players to join"
      next_game = my_future_game.next_version( :wait => 25 )
      puts "next_game #{!!next_game} #{ my_future_game.players.size} #{my_future_game.min_players}"
      if next_game
        my_future_game = next_game
      end
      if my_future_game.players.size >= my_future_game.min_players
        puts "Trying to start game"
        my_future_game.start = true
        my_future_game.save!
        play_game( my_future_game )
        return true
      end
    end
    return false
  end

  def play_other_game
    puts "Looking for other game to join"
    other_games = find_other_games( Clooneys::Game::FUTURE ) #find future games
    #don't consider games @user created nor games with people the @user doesn't want to play
    other_games.delete_if { |g| g.creator_id == @user.id || g.has_login?( @user.no_play_logins )}
    puts "remaining other games: #{other_games}"
    other_game = other_games.sample
    #join the game if not already joined
    if other_game && !other_game.player_for_user( @user )
      #other_game = Clooneys::Game.all.first
      puts "Found this game to join: #{other_game.id} #{other_game.players.inspect}"
      player = other_game.join( @user )
      if player.errors.size > 0
        puts "Could not join game"
        puts player.errors.to_a.join ','
        other_game = nil
      else
        puts "Joined game"
      end
    end
    #wait for the creator of this game to start it
    if other_game
      puts "Waiting for joined game to start: #{other_game.id}"
      next_game = other_game.next_version( :wait => 25 )
      if next_game && next_game.started?
        play_game( next_game )
      else
        puts "Unjoining game"
        begin
          other_game.unjoin( @user )
        rescue Exception => exc #TODO: use more specific exception
          puts "Could not unjoin game: #{exc.to_s}"
          puts other_game.errors.to_a.join ','
        end
      end
    else
      puts "No other games to join, sleeping"
      sleep 30
    end
  end

  def find_my_game( filter, options = {} )
    game = Clooneys::Game.all( filter, options ).first
    return unless game
    yield( game ) if block_given?
    game
  end

  def find_other_game( filter, options = {} )
    games = Clooneys::Game.all( filter, options )
    game = nil
    games.reverse.each { |g| game = g unless g.creator_id == @user.id }
    return unless game
    yield( game ) if block_given?
    game
  end

  def find_other_games( filter, options = {} )
    Clooneys::Game.all( filter, options )
  end

  def play_game( game )
    intelligence = @klass.new( game, @user )
    intelligence.start
  end

  def refresh_games
    @games = Clooneys::Game.all
    @games.reverse.each do |game|
      game.players.each {|p| @game = game if p.user_id == @user.id}
    end
  end
end
