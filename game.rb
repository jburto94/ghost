require 'byebug'
require_relative "player"

class Game
  def initialize(*players)
    @players = players.map { |player| Player.new(player) }
    @fragment = ""
    @dictionary = {}
    file = File.open(File.join(File.dirname(__FILE__), "dictionary.txt"))
    file.readlines.each { |word| @dictionary[word.chomp] = true }
  end

  def active_players
    @players.select { |player| player.losses < 5 }
  end

  def current_player
    playing = self.active_players
    player_index = @fragment.length % playing.length
    playing[player_index]
  end

  def previous_player
    playing = self.active_players
    player_index = (@fragment.length % playing.length) - 1
    playing[player_index]
  end

  def next_player
    self.current_player
    self.previous_player
  end

  def valid_play?(letter)
    query = @fragment + letter
    return false if letter.length != 1 || !(letter.match?(/[[:alpha:]]/))
    return false if !(@dictionary.keys.grep(/#{query}[a-z]+/).any?)
    true
  end

  def take_turn(player)

    # Retrieve letter from player and make it lowercase
    print "#{current_player.name}, enter a letter or 'guess' to make a guess: "
    letter = gets.chomp.downcase

    if letter == "guess"
      guess_result = current_player.guess(@fragment, @dictionary)
      guess_result ? end_round(previous_player) : end_round(current_player)
      return false
    end

    while valid_play?(letter) == false
      if letter == "guess"
        guess_result = current_player.guess(@fragment, @dictionary)
        guess_result ? end_round(previous_player) : end_round(current_player)
        return false
      end
      p "Incorrect input, try again"
      p @fragment
      print "#{current_player.name}, enter a letter or 'guess' to make a guess: "
      letter = gets.chomp.downcase
    end

    @fragment += letter
    p @fragment
    true
  end

  def display_losses(losses)
    losses_ghost = "GHOST"
    player_losses = ""
    (0...losses).each { |loss| player_losses += losses_ghost[loss] }
    player_losses
  end

  def standings
    p "--------------------"
    p "SCOREBOARD"
    p "--------------------"
    @players.each do |player|
      p "#{player.name}: #{self.display_losses(player.losses)}"
    end
  end

  def play_round
    self.next_player
    @fragment = ""

    while self.take_turn(self.current_player) == true
      self.next_player
    end
  end

  def end_round(losing_player)
    losing_player.losses += 1
    p "------------------------"
    p "#{losing_player.name} has lost the round."
    self.standings
    p "------------------------"
    p "END OF THE ROUND"
    p "------------------------"
    true
  end

  def play_game
    playing = self.active_players
    while playing.length > 1
      self.play_round
      playing = self.active_players
    end
    p "Final Standings:"
    self.standings
    p "Congratulations! #{playing[0].name} has won the game!"
  end
end

