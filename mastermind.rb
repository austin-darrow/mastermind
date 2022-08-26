require 'pry-byebug'

class CodeGen
  @@COLORS = ['R', 'O', 'Y', 'B', 'I', 'V']

  attr_reader :code

  def initialize
    @code = {}
    generate_code
  end

  def generate_code
    # puts "How long should the code be? Enter an integer (rec: 4-6)."
    # code_length = gets.chomp.to_i
    for i in 1..4 #code_length
      @code[i] = @@COLORS.sample
    end
  end
end

class HumanPlayer
  @@COLORS = ['R', 'O', 'Y', 'B', 'I', 'V']

  def initialize
  end

  def make_guess
    puts "Color options: #{@@COLORS}"
    guess = {}
    for i in 1..4
      puts "Enter your guess for position #{i} color:"
      guess[i] = gets.chomp.upcase
      until @@COLORS.any?(guess[i])
        puts "Invalid guess"
        guess[i] = gets.chomp.upcase
      end
    end
    guess
  end

  def generate_code
    puts "Code options: #{@@COLORS}"
    @code = {}
    for i in 1..4
      puts "Enter code for position #{i}:"
      @code[i] = gets.chomp.upcase
      until @@COLORS.any?(@code[i])
        puts "Invalid code"
        @code[i] = gets.chomp.upcase
      end
    end
    @code
  end

  def to_s
    "You"
  end
end

class ComputerPlayer
  attr_reader :combos

  @@COLORS = ['R', 'O', 'Y', 'B', 'I', 'V']

  def initialize
    # @combos = @@COLORS.repeated_permutation(4).to_a
    # @exact = 0
    # @near = 0
    @code = nil
    @guess = {}
  end

  # def get_feedback(exact, near)
  #   @exact = exact
  #   @near = near
  # end

  def get_code(code)
    @code = code
  end

  def make_guess
    @code.each do |k, v|
      if @code[k] == @guess[k]
        next
      else
        @guess[k] = @@COLORS.sample
      end
    end
    @guess
  end

  def to_s
    "The Computer"
  end
end

class Game
  attr_reader :round, :HumanScore, :ComputerScore, :player

  def initialize
    @round = 1
    @HumanScore, @ComputerScore = 0
    @player = nil
    player_setup
    game_setup
    @exact = 0
    @near = 0
    @history = []
  end

  def player_setup
    clear_console
    puts "Do you want to be A: Codemaker or B: Codebreaker?"
    response = gets.chomp.downcase
    if response == 'a'
      @player = ComputerPlayer.new
    elsif response == 'b'
      @player = HumanPlayer.new
    else
      player_setup
    end
  end

  def game_setup
    clear_console
    if @player.is_a?(ComputerPlayer)
      @code = HumanPlayer.new.generate_code
      @player.get_code(@code)
    else
      @code = CodeGen.new.code
    end
    # @code = {1=>"blu", 2=>"red", 3=>"yel", 4=>"yel"} FOR TESTING
  end

  def play_round
    track_history("Round:#{@round}/12 | ") # Fix display spacing when round is double-digits
    prep_next_round
    @guess = @player.make_guess
    track_history("Guess:#{@guess} | ")
    check_answers
    track_history("#{feedback}\n")
  end

  def play_game
    loop do
      play_round
      break if game_over? == true
    end
  end

  def check_answers
    temp_code = deep_copy(@code)
    temp_guess = deep_copy(@guess)

    temp_guess.each do |guess_k, guess_v|
      if temp_guess[guess_k] == temp_code[guess_k]
        @exact += 1
        temp_guess.delete(guess_k)
        temp_code.delete(guess_k)
      end
    end
    temp_guess.each do |guess_k, guess_v|
      switch = 0
      temp_code.each do |code_k, code_v|
        if switch == 1
          next
        end
        if guess_v == code_v
          @near += 1
          temp_guess.delete(guess_k)
          temp_code.delete(code_k)
          switch = 1
        end
      end
    end
  end

  def track_history(item)
    @history.push(item)
  end

  def feedback
    "Exact: #{@exact} Near: #{@near}"
  end

  def prep_next_round
    clear_console
    puts "#{@history.join('')}"
    # @player.get_feedback(@exact, @near)
    @round += 1
    @exact = 0
    @near = 0
  end

  def clear_console
    puts %x(/usr/bin/clear)
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end

  def game_over?
    if @exact == 4
      clear_console
      puts "#{@history.join('')}"
      puts "\n#{@player} broke the code!\n"
      return true
    elsif @round > 12
      clear_console
      puts "#{@history.join('')}"
      puts "\nThat was the final round. Game over!\n"
      return true
    else
      puts "\nNext round!\n"
      return false
    end
  end
end

test = Game.new
test.play_game
