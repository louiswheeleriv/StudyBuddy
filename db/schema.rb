# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171205021619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "phases", force: :cascade do |t|
    t.integer "study_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "phase_index"
    t.index ["study_id"], name: "index_phases_on_study_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "phase_id"
    t.integer "hour_offset"
    t.integer "every_n_days"
    t.text "question_text"
    t.string "answer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_id"], name: "index_questions_on_phase_id"
  end

  create_table "studies", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_data", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.text "data1"
    t.text "data2"
    t.text "data3"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_data_on_question_id"
    t.index ["user_id"], name: "index_user_data_on_user_id"
  end

  create_table "user_phases", force: :cascade do |t|
    t.integer "phase_id"
    t.integer "user_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_id"], name: "index_user_phases_on_phase_id"
    t.index ["user_id"], name: "index_user_phases_on_user_id"
  end

  create_table "user_schedules", force: :cascade do |t|
    t.integer "user_id"
    t.string "schedule_type"
    t.string "time_of_day"
    t.integer "day_of_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_schedules_on_user_id"
  end

  create_table "user_studies", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "study_id"
    t.string "participant_number"
    t.boolean "participant_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_id"], name: "index_user_studies_on_study_id"
    t.index ["user_id"], name: "index_user_studies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "is_admin"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "username", null: false
    t.string "password_digest"
    t.string "email"
    t.string "phone"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "user_studies", "studies"
  add_foreign_key "user_studies", "users"
end
