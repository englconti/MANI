# Every level, the XP each one needs and how far the person is from the next
class LevelsController < ApplicationController
  def index
    @xp = current_user.xp
    @level = current_user.level
    @levels = PlayerLevel.all(@xp)
    @answers_to_next = (@level.xp_to_next.to_f / LessonCompletion::XP_PER_CORRECT_ANSWER).ceil
  end
end
