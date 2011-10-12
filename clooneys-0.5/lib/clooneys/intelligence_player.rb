class Clooneys::IntelligencePlayer

  def initialize( klass, user )
    @klass = klass
    raise "no klass" unless @klass
    @user = user
    raise "no user" unless @user
  end

  def start
    while true
      refresh_games
      unless @game
        @game = Clooneys::Game.new( :bid_time => 60 )
        @game.save!
      end
      unless @game.started?
        next_game = nil
        while true
          next_game = @game.next_version( :wait => 25 )
          puts "next_game #{!!next_game} #{ @game.players.size} #{@game.min_players}"
          break if !next_game && @game.players.size >= @game.min_players
          @game = next_game if next_game
        end
        @game.start = true
        @game.save!
      end
      intelligence = @klass.new( @game, @user )
      intelligence.start
    end
  end

  def refresh_games
    @games = Clooneys::Game.all + Clooneys::Game.all( "present" )
    @games.reverse.each do |game|
      game.players.each {|p| @game = game if p.user_id == @user.id}
    end
  end
end
