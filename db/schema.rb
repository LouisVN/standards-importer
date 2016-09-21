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

  create_table "jurisdictions", force: :cascade do |t|
    t.string "csp_id",   limit: 255
    t.string "document", limit: 255
    t.string "title",    limit: 255
    t.string "type",     limit: 255
  end

  add_index "jurisdictions", ["csp_id"], name: "index_jurisdictions_on_csp_id", using: :btree

  create_table "standards", force: :cascade do |t|
    t.integer "jurisdiction_id", limit: 4,                   null: false
    t.string  "csp_id",          limit: 255
    t.string  "title",           limit: 255
    t.string  "subject",         limit: 255
    t.string  "document",        limit: 255
    t.boolean "indexed",                     default: false, null: false
    t.integer "child_count",     limit: 4,   default: 0
  end

  add_index "standards", ["csp_id"], name: "index_standards_on_csp_id", using: :btree
  add_index "standards", ["jurisdiction_id"], name: "index_standards_on_jurisdiction_id", using: :btree

  create_table "standards_education_levels", id: false, force: :cascade do |t|
    t.integer "standard_id",     limit: 4,   default: 0,  null: false
    t.string  "education_level", limit: 255, default: "", null: false
  end

  add_index "standards_education_levels", ["standard_id"], name: "index_standards_education_levels_on_standard_id", using: :btree

  create_table "standards_schema_migrations", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "standards_schema_migrations", ["version"], name: "unique_schema_migrations", unique: true, using: :btree

  create_table "standards_standards", id: false, force: :cascade do |t|
    t.integer "parent_id", limit: 4, default: 0, null: false
    t.integer "child_id",  limit: 4, default: 0, null: false
  end

  add_index "standards_standards", ["child_id"], name: "index_standards_standards_on_child_id", using: :btree
  add_index "standards_standards", ["parent_id"], name: "index_standards_standards_on_parent_id", using: :btree

  add_foreign_key "standards", "jurisdictions"
  add_foreign_key "standards_education_levels", "standards"
  add_foreign_key "standards_standards", "standards", column: "child_id"
  add_foreign_key "standards_standards", "standards", column: "parent_id"
end