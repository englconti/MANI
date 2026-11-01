# The player's level, from the total XP. Names follow the money: from a piggy bank to a master.
class PlayerLevel
  # Each level asks for more than the one before. The lessons give 5 XP per right answer, 505 XP
  # in all, so the last level (480) needs almost every answer right, in every lesson.
  LEVELS = [["Cofrinho", 0], ["Poupador", 75], ["Investidor", 170], ["Estrategista", 275], ["Mestre", 365],
            ["Sábio", 430], ["Lenda", 480]].freeze

  # One row of the list of all levels. state: :done, :current or :locked
  Entry = Struct.new(:number, :name, :from, :to, :state, keyword_init: true)

  attr_reader :number, :name, :floor, :ceiling, :next_name

  # Every level with its XP range and where this XP stands in them
  def self.all(xp)
    current = self.for(xp).number
    LEVELS.each_with_index.map do |(name, from), index|
      number = index + 1
      to = LEVELS[index + 1]&.last
      state = number < current ? :done : (number == current ? :current : :locked)
      Entry.new(number: number, name: name, from: from, to: to, state: state)
    end
  end

  def self.for(xp)
    xp = [xp.to_i, 0].max
    index = LEVELS.rindex { |_name, minimum| xp >= minimum }
    new(index, xp)
  end

  def initialize(index, xp)
    @index = index
    @xp = xp
    @number = index + 1
    @name, @floor = LEVELS[index]
    @next_name, @ceiling = LEVELS[index + 1]
  end

  def max?
    @ceiling.nil?
  end

  def xp_into_level
    @xp - @floor
  end

  def xp_for_level
    max? ? 0 : @ceiling - @floor
  end

  def xp_to_next
    max? ? 0 : @ceiling - @xp
  end

  # Progress inside the current level, 0 to 100
  def percent
    max? ? 100 : (xp_into_level * 100 / xp_for_level)
  end
end
