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

ActiveRecord::Schema[8.1].define(version: 2026_05_15_221847) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invite_token"
    t.string "nome"
    t.integer "professor_id"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", default: "", null: false
    t.integer "nivel", default: 1, null: false
    t.string "password_digest", null: false
    t.string "perfil_acessibilidade"
    t.string "role", default: "aluno", null: false
    t.integer "sequencia_dias", default: 0, null: false
    t.bigint "turma_id"
    t.datetime "updated_at", null: false
    t.integer "xp_total", default: 0, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["turma_id"], name: "index_users_on_turma_id"
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "users", "turmas"
end
