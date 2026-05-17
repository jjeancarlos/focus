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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_040435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "atividades", force: :cascade do |t|
    t.boolean "ativo", default: true, null: false
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.text "descricao", null: false
    t.string "imagem_url"
    t.jsonb "perguntas", default: [], null: false
    t.string "tipo", null: false
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.integer "xp_base", default: 20, null: false
    t.index ["ativo"], name: "index_atividades_on_ativo"
    t.index ["tipo"], name: "index_atividades_on_tipo"
  end

  create_table "recados", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "mensagem"
    t.integer "professor_id"
    t.integer "turma_id"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tentativas", force: :cascade do |t|
    t.bigint "aluno_id", null: false
    t.bigint "atividade_id"
    t.datetime "concluida_em", null: false
    t.datetime "created_at", null: false
    t.integer "pontuacao", default: 0, null: false
    t.integer "tempo_gasto", default: 0, null: false
    t.string "tipo_missao", null: false
    t.datetime "updated_at", null: false
    t.integer "xp_ganho", default: 0, null: false
    t.index ["aluno_id"], name: "index_tentativas_on_aluno_id"
    t.index ["atividade_id"], name: "index_tentativas_on_atividade_id"
    t.index ["concluida_em"], name: "index_tentativas_on_concluida_em"
    t.index ["tipo_missao"], name: "index_tentativas_on_tipo_missao"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "tentativas", "atividades"
  add_foreign_key "tentativas", "users", column: "aluno_id"
  add_foreign_key "users", "turmas"
end
