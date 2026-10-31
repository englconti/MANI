# The player's level, from the total XP. Names follow the money: from a piggy bank to a master.
class PlayerLevel
  LEVELS = [["Cofrinho", 0], ["Poupador", 50], ["Investidor", 120], ["Estrategista", 220], ["Mestre", 340]].freeze

  attr_reader :number, :name, :floor, :ceiling, :next_name

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
