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

  create_table "education_levels", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "education_levels_standards", id: false, force: :cascade do |t|
    t.integer "standard_id",        limit: 4, null: false
    t.integer "education_level_id", limit: 4, null: false
  end

  add_index "education_levels_standards", ["education_level_id"], name: "index_education_levels_standards_on_education_level_id", using: :btree
  add_index "education_levels_standards", ["standard_id"], name: "index_education_levels_standards_on_standard_id", using: :btree

  create_table "jurisdictions", force: :cascade do |t|
    t.string "csp_id",   limit: 255
    t.string "document", limit: 255
    t.string "title",    limit: 255
    t.string "type",     limit: 255
  end

  add_index "jurisdictions", ["csp_id"], name: "index_jurisdictions_on_csp_id", using: :btree

  create_table "parents", force: :cascade do |t|
  end

  create_table "parents_standards", id: false, force: :cascade do |t|
    t.integer "standard_id", limit: 4, null: false
    t.integer "parent_id",   limit: 4, null: false
  end

  add_index "parents_standards", ["parent_id"], name: "index_parents_standards_on_parent_id", using: :btree
  add_index "parents_standards", ["standard_id"], name: "index_parents_standards_on_standard_id", using: :btree

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

  create_table "standards_schema_migrations", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "standards_schema_migrations", ["version"], name: "unique_schema_migrations", unique: true, using: :btree

  add_foreign_key "education_levels_standards", "education_levels"
  add_foreign_key "education_levels_standards", "standards"
  add_foreign_key "parents_standards", "parents"
  add_foreign_key "parents_standards", "standards"
  add_foreign_key "standards", "jurisdictions"
end
