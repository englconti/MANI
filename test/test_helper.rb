ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers (DRb needs UNIX sockets, so not on Windows)
  parallelize(workers: :number_of_processors) unless Gem.win_platform?

  # Builds a lesson with `count` abcd questions (correct answer is always "a").
  # Must run before the users that need answers are created.
  def create_lesson(title: "Lesson #{SecureRandom.hex(3)}", count: 3, question_type: "abcd", prerequisite: nil)
    lesson = Lesson.create!(title: title, description: "desc", prerequisite: prerequisite,
                            level: prerequisite ? 2 : 1)
    count.times do |i|
      Question.create!(lesson: lesson, question_type: question_type, level: 1,
                       statement: "Question #{i}", a: "a", b: "b", c: "c", d: "d",
                       correct_answer: question_type == "writing" ? "palavra" : "a")
    end
    lesson
  end

  def create_user(username: "user#{SecureRandom.hex(3)}", email: "#{SecureRandom.hex(4)}@example.com")
    User.create!(username: username, email: email, password: "senha1234",
                 birthday: Time.zone.local(2000, 1, 1))
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
