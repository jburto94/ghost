require_relative('game.rb')

class Player
  attr_accessor :name, :losses
  
  def initialize(name)
    @name = name
    @losses = 0
  end

  def guess(word, dictionary)
    dictionary[word] ? true : false
  end
end