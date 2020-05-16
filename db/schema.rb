# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_15_204706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connectors", id: :serial, force: :cascade do |t|
    t.integer "uid"
    t.string "service", limit: 255
    t.integer "prio"
    t.string "uri", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "covers", id: :serial, force: :cascade do |t|
    t.integer "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "counter"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "comment", limit: 255
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "first_page_only", default: false, null: false
    t.integer "page_count", default: 0, null: false
    t.date "delete_at"
    t.boolean "no_delete"
    t.boolean "complete_pdf", default: false
    t.integer "folder_id"
    t.integer "cover_id"
    t.boolean "delta", default: true, null: false
    t.index ["delta"], name: "index_documents_on_delta"
  end

  create_table "folders", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cover_ind"
    t.string "short_name", limit: 255
  end

  create_table "logs", id: :serial, force: :cascade do |t|
    t.string "source", limit: 255
    t.string "message", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "messagetype"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.integer "org_folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_filename", limit: 255
    t.integer "source"
    t.text "content"
    t.integer "document_id"
    t.integer "position", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.boolean "backup", default: false, null: false
    t.integer "org_cover_id"
    t.integer "fid"
    t.string "mime_type", limit: 255
    t.boolean "ocr", default: false
    t.boolean "pdf_exists", default: false
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type", limit: 20
    t.integer "tagger_id"
    t.string "tagger_type", limit: 20
    t.string "context", limit: 50
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

end
