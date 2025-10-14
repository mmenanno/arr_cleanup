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

ActiveRecord::Schema[8.0].define(version: 2025_10_14_025136) do
  create_table "app_settings", force: :cascade do |t|
    t.string "radarr_url"
    t.text "radarr_api_key"
    t.string "sonarr_url"
    t.text "sonarr_api_key"
    t.datetime "radarr_last_synced_at"
    t.datetime "sonarr_last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "episodes", force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "episode_number", null: false
    t.string "title"
    t.string "file_path"
    t.bigint "size_bytes"
    t.string "quality_profile"
    t.string "quality"
    t.boolean "is_remux", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "episode_number"], name: "index_episodes_on_season_id_and_episode_number", unique: true
    t.index ["season_id"], name: "index_episodes_on_season_id"
    t.index ["size_bytes"], name: "index_episodes_on_size_bytes"
    t.index ["title"], name: "index_episodes_on_title"
  end

  create_table "job_errors", force: :cascade do |t|
    t.string "service_type", null: false
    t.string "error_class"
    t.text "error_message"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_job_errors_on_occurred_at"
    t.index ["service_type"], name: "index_job_errors_on_service_type"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title", null: false
    t.integer "year"
    t.integer "tmdb_id"
    t.integer "radarr_id", null: false
    t.string "file_path"
    t.bigint "size_bytes"
    t.string "quality_profile"
    t.string "quality"
    t.boolean "is_remux", default: false, null: false
    t.boolean "ignored", default: false, null: false
    t.datetime "last_refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ignored"], name: "index_movies_on_ignored"
    t.index ["is_remux"], name: "index_movies_on_is_remux"
    t.index ["radarr_id"], name: "index_movies_on_radarr_id", unique: true
    t.index ["size_bytes"], name: "index_movies_on_size_bytes"
    t.index ["title"], name: "index_movies_on_title"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "season_number", null: false
    t.bigint "total_size_bytes", default: 0
    t.boolean "contains_remux", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["show_id", "season_number"], name: "index_seasons_on_show_id_and_season_number", unique: true
    t.index ["show_id"], name: "index_seasons_on_show_id"
    t.index ["total_size_bytes"], name: "index_seasons_on_total_size_bytes"
  end

  create_table "shows", force: :cascade do |t|
    t.string "title", null: false
    t.integer "year"
    t.integer "tvdb_id"
    t.integer "sonarr_id", null: false
    t.bigint "total_size_bytes", default: 0
    t.boolean "contains_remux", default: false, null: false
    t.boolean "ignored", default: false, null: false
    t.datetime "last_refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contains_remux"], name: "index_shows_on_contains_remux"
    t.index ["ignored"], name: "index_shows_on_ignored"
    t.index ["sonarr_id"], name: "index_shows_on_sonarr_id", unique: true
    t.index ["title"], name: "index_shows_on_title"
    t.index ["total_size_bytes"], name: "index_shows_on_total_size_bytes"
  end

  create_table "sync_statuses", force: :cascade do |t|
    t.string "service_type", null: false
    t.string "status", null: false
    t.integer "progress_current", default: 0
    t.integer "progress_total", default: 0
    t.string "message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_sync_count", default: 0
    t.index ["service_type"], name: "index_sync_statuses_on_service_type", unique: true
    t.index ["status"], name: "index_sync_statuses_on_status"
  end

  add_foreign_key "episodes", "seasons"
  add_foreign_key "seasons", "shows"
end
