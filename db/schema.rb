# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_01_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "avatar_purchases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "avatar_key", null: false
    t.integer "price", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "avatar_key"], name: "index_avatar_purchases_on_user_id_and_avatar_key", unique: true
    t.index ["user_id"], name: "index_avatar_purchases_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "asker_id"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: false
    t.index ["asker_id"], name: "index_friendships_on_asker_id"
    t.index ["receiver_id"], name: "index_friendships_on_receiver_id"
  end

  create_table "information", force: :cascade do |t|
    t.string "text"
    t.string "img_url"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lesson_completions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_id", null: false
    t.integer "correct_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_lesson_completions_on_lesson_id"
    t.index ["user_id", "lesson_id"], name: "index_lesson_completions_on_user_id_and_lesson_id", unique: true
    t.index ["user_id"], name: "index_lesson_completions_on_user_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.integer "level", default: 1, null: false
    t.bigint "prerequisite_id"
    t.string "track"
    t.string "intro_title"
    t.text "intro_text"
    t.string "intro_image"
    t.index ["position"], name: "index_lessons_on_position"
    t.index ["prerequisite_id"], name: "index_lessons_on_prerequisite_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "question_type"
    t.integer "level"
    t.string "statement"
    t.bigint "lesson_id", null: false
    t.string "a"
    t.string "b"
    t.string "c"
    t.string "d"
    t.string "img_url"
    t.string "correct_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "explanation"
    t.text "context"
    t.index ["lesson_id"], name: "index_questions_on_lesson_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "xp", default: 0
    t.string "username", null: false
    t.datetime "birthday", precision: nil, null: false
    t.integer "lives", default: 5
    t.integer "manis", default: 0
    t.datetime "lives_recharge_started_at"
    t.integer "streak_count", default: 0, null: false
    t.date "last_study_on"
    t.integer "daily_goal", default: 20, null: false
    t.string "avatar_key", default: "mani", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "xp_days", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "day", null: false
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_xp_days_on_day"
    t.index ["user_id", "day"], name: "index_xp_days_on_user_id_and_day", unique: true
    t.index ["user_id"], name: "index_xp_days_on_user_id"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "avatar_purchases", "users"
  add_foreign_key "friendships", "users", column: "asker_id"
  add_foreign_key "friendships", "users", column: "receiver_id"
  add_foreign_key "lesson_completions", "lessons"
  add_foreign_key "lesson_completions", "users"
  add_foreign_key "lessons", "lessons", column: "prerequisite_id"
  add_foreign_key "questions", "lessons"
  add_foreign_key "xp_days", "users"
end
