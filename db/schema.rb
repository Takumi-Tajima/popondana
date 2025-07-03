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

ActiveRecord::Schema[8.0].define(version: 2025_07_03_132923) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "isbn", null: false
    t.string "title", null: false
    t.string "author"
    t.string "publisher"
    t.date "published_date"
    t.string "image_url"
    t.string "rakuten_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ownership_categories", force: :cascade do |t|
    t.bigint "ownership_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_ownership_categories_on_category_id"
    t.index ["ownership_id", "category_id"], name: "index_ownership_categories_on_ownership_id_and_category_id", unique: true
    t.index ["ownership_id"], name: "index_ownership_categories_on_ownership_id"
  end

  create_table "ownerships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "owned_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "book_id", null: false
    t.index ["book_id"], name: "index_ownerships_on_book_id"
    t.index ["user_id"], name: "index_ownerships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
  end

  add_foreign_key "ownership_categories", "categories"
  add_foreign_key "ownership_categories", "ownerships"
  add_foreign_key "ownerships", "books"
  add_foreign_key "ownerships", "users"
end
