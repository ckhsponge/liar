#!/usr/bin/ruby

require 'user'
require 'game'
class Console
  def start
    sign_in
    list_games
#@game = game_for_id 17
#odds
    while true
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
          list_games
        when "destroy_game"
          destroy_game_command
          list_games
        when "start_game"
          start_game_command
        when "join_game"
          join_game_command
          list_games
        when "play_game"
          play_game_command
          odds
        when "unjoin"
          game_for_id(@command_ints[0]).unjoin( @user )
          list_games
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
    find_game do
      @game.destroy
      puts "Destroyed game"
      @game = nil
    end
  end

  def start_game_command
    find_game do
      @game.start = true
      if @game.save
        puts "Game started"
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
      end
    end
  end

  def play_game_command
    find_game do
      
    end
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

  def find_game
    if @command_ints.size < 1
      puts "Please enter a game id"
    else
      @game = game_for_id( @command_ints[0] )
      if !@game
        "No game with id #{@command_ints[0]} found"
      else
        yield
      end
    end
  end
end

Console.new.start
