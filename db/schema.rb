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

ActiveRecord::Schema[7.0].define(version: 2024_06_02_201741) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "ollama_message_role", ["system", "assistant", "user"]

  create_table "ollama_chunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "data", null: false
    t.vector "embedding", limit: 4096
    t.integer "token_count", null: false
    t.index ["created_at"], name: "index_ollama_chunks_on_created_at"
    t.index ["updated_at"], name: "index_ollama_chunks_on_updated_at"
  end

  create_table "ollama_chunks_messages", id: false, force: :cascade do |t|
    t.bigint "ollama_chunk_id", null: false
    t.bigint "ollama_message_id", null: false
    t.index ["ollama_chunk_id", "ollama_message_id"], name: "index_chunk_messages_on_chunk_id_and_message_id"
    t.index ["ollama_message_id", "ollama_chunk_id"], name: "index_chunk_messages_on_message_id_and_chunk_id"
  end

  create_table "ollama_consumed_messages", force: :cascade do |t|
    t.uuid "event_id"
    t.string "aggregate"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "aggregate"], name: "index_ollama_consumed_messages_event_id_and_agg", unique: true
    t.index ["status"], name: "index_ollama_consumed_messages_status"
  end

  create_table "ollama_conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ollama_events", force: :cascade do |t|
    t.json "data"
    t.bigint "ollama_message_id"
    t.bigint "ollama_conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ollama_conversation_id"], name: "index_ollama_events_on_ollama_conversation_id"
    t.index ["ollama_message_id"], name: "index_ollama_events_on_ollama_message_id"
  end

  create_table "ollama_messages", force: :cascade do |t|
    t.enum "role", default: "system", null: false, enum_type: "ollama_message_role"
    t.text "content"
    t.bigint "ollama_conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ollama_conversation_id"], name: "index_ollama_messages_on_ollama_conversation_id"
  end

  create_table "ollama_outboxes", force: :cascade do |t|
    t.uuid "identifier", null: false
    t.string "event", null: false
    t.jsonb "payload"
    t.string "aggregate", null: false
    t.uuid "aggregate_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aggregate_identifier"], name: "index_ollama_outboxes_on_aggregate_identifier"
    t.index ["identifier"], name: "index_ollama_outboxes_on_identifier", unique: true
  end

  create_table "transactional_outbox_outboxes", force: :cascade do |t|
    t.string "aggregate", null: false
    t.string "aggregate_identifier", null: false
    t.string "event", null: false
    t.uuid "identifier", null: false
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_transactional_outbox_outboxes_on_identifier"
  end

end
