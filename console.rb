#!/usr/bin/ruby

class Fixnum
  def factorial
    return 1 if self == 0
    self.downto(1).inject(:*)
  end

  def choose( k )
    self.factorial / ( k.factorial * (self - k).factorial )
  end
end

require 'user'
require 'game'
class Console
  def start
    sign_in
    list_games
    @games.reverse.each do |game|
      game.players.each {|p| @game = game if p.user_id == @user.id}
    end
    while true
      if @game
        puts "--- PLAYING ---"
        @game.print_status( @user )
        puts "---------------"
      end
      putc '>'
      putc ' '
      command = gets.chomp
      @command_ints = command.split(" ").collect{|i| i.to_i}[1,100]
      case command.split(" ").first
        when "list_games"
          list_games
        when "list_active_games"
          list_active_games
        when "create_game"
          create_game_command
        when "destroy_game"
          destroy_game_command
          list_games
        when "start_game"
          start_game_command
        when "join_game"
          join_game_command
        when "play_game"
          play_game_command
        when "r"
          ensure_game { @game.reload }
        when "odds"
          ensure_game { odds }
        when "bid"
          ensure_game { bid_command( @game, @command_ints[0], @command_ints[1]); @game.reload }
        when "bullshit"
          ensure_game { @game.make_bid_bullshit( @user ); @game.reload }
        when "unjoin"
          ensure_game { @game.unjoin( @user ); list_games }
      end
    end
  end

  def list_games
    @games = Game.all + Game.all( "present" )
    puts "--- Games ---"
    @games.each do |game|
      puts game.to_s
    end
    puts "-------------"
  end

  def list_active_games
    @games = Game.all( "present" )
    puts "--- Games ---"
    @games.each do |game|
      puts game.to_s
    end
    puts "-------------"
  end

  def create_game_command
    @game = Game.new( :bid_time => 300, :name => "#{@user.login} #{Time.now.strftime "%Y%m%d%H%M"}")
    if @game.save
      puts "Created game #{@game.name}"
    else
      puts @game.errors.inspect
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
        puts @game.errors.inspect
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
    @game.print_odds @user
  end
  
  def game_for_id( id )
    @games.each do |game|
      return game if id == game.id
    end
    return nil
  end

  def sign_in
    unless ( @user = User.me )
      puts "user not found"
      @user = User.new_me
      if @user.save
        puts "Created a new user: #{@user.login}"
      else
        raise "Failed to create a new user, maybe you forgot your password: #{@user.errors.inspect}"
      end
    end
    puts "Signed in #{@user.login}"
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
      @game = Game.find( @command_ints[0] )
      if !@game
        "No game with id #{@command_ints[0]} found"
      else
        yield
      end
    end
  end
end

Console.new.start
