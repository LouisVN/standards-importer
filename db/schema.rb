# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161021101447) do

  create_table "EducationLevel", id: false, force: :cascade do |t|
    t.integer "standard_id",     limit: 4,  default: 0,  null: false
    t.string  "education_level", limit: 50, default: "", null: false
  end

  add_index "EducationLevel", ["standard_id"], name: "index_EducationLevel_on_standard_id", using: :btree

  create_table "Jurisdiction", force: :cascade do |t|
    t.string "csp_id",   limit: 100
    t.text   "document", limit: 65535
    t.string "title",    limit: 255
    t.string "type",     limit: 255
  end

  add_index "Jurisdiction", ["csp_id"], name: "index_Jurisdiction_on_csp_id", unique: true, using: :btree

  create_table "Standard", force: :cascade do |t|
    t.integer "jurisdiction_id", limit: 4,                     null: false
    t.string  "csp_id",          limit: 100
    t.string  "title",           limit: 255
    t.string  "subject",         limit: 255
    t.text    "document",        limit: 65535
    t.boolean "indexed",                       default: false, null: false
    t.integer "child_count",     limit: 4,     default: 0
  end

  add_index "Standard", ["csp_id"], name: "index_Standard_on_csp_id", unique: true, using: :btree
  add_index "Standard", ["jurisdiction_id"], name: "index_Standard_on_jurisdiction_id", using: :btree

  create_table "Standard_Standard", id: false, force: :cascade do |t|
    t.integer "parent_id", limit: 4, default: 0, null: false
    t.integer "child_id",  limit: 4, default: 0, null: false
  end

  add_index "Standard_Standard", ["child_id"], name: "index_Standard_Standard_on_child_id", using: :btree
  add_index "Standard_Standard", ["parent_id"], name: "index_Standard_Standard_on_parent_id", using: :btree

  create_table "standards_schema_migrations", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "standards_schema_migrations", ["version"], name: "unique_schema_migrations", unique: true, using: :btree

  add_foreign_key "EducationLevel", "Standard", column: "standard_id"
  add_foreign_key "Standard", "Jurisdiction", column: "jurisdiction_id"
  add_foreign_key "Standard_Standard", "Standard", column: "child_id"
  add_foreign_key "Standard_Standard", "Standard", column: "parent_id"
end
