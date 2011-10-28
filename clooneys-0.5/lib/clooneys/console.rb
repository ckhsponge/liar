class Clooneys::Console
  def initialize( user )
    raise "no user" unless user
    @user = user
  end

  def start
    list_games
    @games.reverse.each do |game|
      game.players.each {|p| @game = game if p.user_id == @user.id}
    end
    while true
      begin
        if @game
          puts "--- PLAYING ---"
          @game.print_status( @user )
          puts "---------------"
        end
        putc '>'
        putc ' '
        command = STDIN.gets.chomp
        @command_ints = command.split(" ").collect{|i| i.to_i}[1,100]
        case command.split(" ").first
          when "list"
            list_games
          when "list_active"
            list_active_games
          when "create"
            create_game_command
          when "destroy"
            destroy_game_command
            list_games
          when "start"
            start_game_command
          when "join"
            join_game_command
          when "play"
            play_game_command
          when "r"
            ensure_game { @game.reload }
          when "a"
            ensure_game { auto_play_command }
          when "s"
            intelligence_player = Clooneys::IntelligencePlayer.new( Clooneys::Intelligence, @user )
            intelligence_player.start
          when "w"
            ensure_game {
              intelligence = Clooneys::Intelligence.new( @game, @user )
              #intelligence.wait_for_update
              intelligence.start
            }
          when "t"
            test_command
          when "odds"
            ensure_game { odds }
          when "bid"
            ensure_game { bid_command( @game, @command_ints[0], @command_ints[1]); @game.reload }
          when "bullshit"
            ensure_game { @game.make_bid_bullshit( @user ); @game.reload }
          when "unjoin"
            ensure_game { @game.unjoin( @user ); list_games }
        end
      rescue ActiveResource::ResourceInvalid => arri
        puts "Command failed (#{arri})"
      rescue Clooneys::Exception => exc
        puts "CLOONEYS EXCEPTION: #{exc.to_s}"
      end
    end
  end

  def list_games
    @games = Clooneys::Game.all + Clooneys::Game.all( "present" )
    puts "--- Games ---"
    @games.each do |game|
      puts game.to_s
    end
    puts "-------------"
  end

  def list_active_games
    @games = Clooneys::Game.all( "present" )
    puts "--- Games ---"
    @games.each do |game|
      puts game.to_s
    end
    puts "-------------"
  end

  def test_command
    ogame = nil
    begin
      @game = ogame = Clooneys::Game.new( :bid_time => 300 )
      if @game.save
        puts "Created game #{@game.name}"
      else
        puts @game.errors.to_a.join ','
        @game = nil
        raise Clooneys::Exception.new("Could not create game")
      end
      test_change_name @game
      @game = @game.next_version( :version => 0 )
      test_change_name @game
    rescue Clooneys::Exception => cexc
      puts cexc.to_s
    end
    ogame.destroy
  end

  def test_change_name( game )
    name = "name #{Time.now} #{Time.now.usec}"
    puts "Trying to change name to '#{name}'"
    game.name = name
    if game.save
      puts "Updated game #{game.name}"
    else
      puts game.errors.to_a.join ','
      game = nil
      raise Clooneys::Exception.new("Could not update game")
    end
    game = Clooneys::Game.find(game.id)
    raise Clooneys::Exception.new("Game not found") unless game
    raise Clooneys::Exception.new("Wrong name '#{game.name}' expected '#{name}'") unless game.name == name
  end

  def create_game_command
    bid_time = @command_ints.size >= 1 ? @command_ints[0] : 300
    @game = Clooneys::Game.new( :bid_time => bid_time ) #, :name => "#{@user.login} #{Time.now.strftime "%Y%m%d%H%M"}")
    if @game.save
      puts "Created game #{@game.name}"
    else
      puts @game.errors.to_a.join ','
      @game = nil
    end
  end

  def destroy_game_command
    ensure_game do
      @game.destroy
      puts "Destroyed game"
      @game = nil
    end
  end

  def start_game_command
    ensure_game do
      @game.start = true
      if @game.save
        puts "Game started"
        @game.reload
      else
        puts @game.errors.full_messages.join ','
      end
    end
  end

  def join_game_command
    find_game do
      player = @game.join( @user )
      if player.errors.size > 0
        puts "Could not join game: #{player.errors.inspect}"
      else
        puts "Joined game"
        @game.reload
      end
    end
  end

  def play_game_command
    find_game do

    end
  end

  def bid_command( game, count, die)
    raise "no game" unless game
    raise "no user" unless @user
    raise "no count" unless count
    raise "no die" unless die
    game.make_bid( @user, count, die)
  end

  def odds
    puts "curent: #{@game.bid} odds: #{@game.bid.odds( @user )}" if @game.bid
    intelligence = Clooneys::Intelligence.new( @game, @user )
    bids = intelligence.next_bids
    bids.each do |bid|
      puts "#{bid} odds: #{bid.odds( @user )}"
    end
  end

  def game_for_id( id )
    @games.each do |game|
      return game if id == game.id
    end
    return nil
  end

  def ensure_game
    if @game
      yield
    else
      puts "No game is being played"
    end
  end

  def find_game
    if @command_ints.size < 1
      puts "Please enter a game id"
    else
      @game = Clooneys::Game.find( @command_ints[0] )
      if !@game
        "No game with id #{@command_ints[0]} found"
      else
        yield
      end
    end
  end
end