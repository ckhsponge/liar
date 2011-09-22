#!/usr/bin/ruby

require 'user'
require 'game'
class Console
  def start
    sign_in
    list_games
    while true
      putc '>'
      putc ' '
      command = gets.chomp
      @command_ints = command.split(" ").collect{|i| i.to_i}[1,100]
      case command.split(" ").first
        when "list_games"
          list_games
        when "join"
          join_command
          list_games
        when "unjoin"
          game_for_id(@command_ints[0]).unjoin( @user )
          list_games
      end
    end
  end

  def join_command
      if @command_ints.size < 1
        puts "Please enter a game id"
      else
        @game = game_for_id( @command_ints[0] )
        if !@game
          "No game with id #{@command_ints[0]} found"
        else
          player = @game.join( @user )
          if player.errors.size > 0
            puts "Could not join game: #{player.errors.inspect}"
          else
            puts "Joined game"
          end
        end
      end
  end
  
  def game_for_id( id )
    @games.each do |game|
      return game if id == game.id
    end
    return nil
  end
  
  def list_games
    @games = Game.all
    puts "--- Games ---"
    @games.each do |game|
      puts game.to_s
    end
    puts "-------------"
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
end

Console.new.start
