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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101112011354) do

  create_table "bids", :force => true do |t|
    t.date     "date"
    t.float    "amount"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "component_id"
  end

  create_table "contract_costs", :force => true do |t|
    t.date     "date"
    t.float    "amount"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.string   "contractor"
    t.float    "bid"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deadlines", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "derived_quantities", :force => true do |t|
    t.string   "name"
    t.float    "multiplier"
    t.integer  "component_id"
    t.integer  "parent_quantity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_cost_estimates", :force => true do |t|
    t.string   "name"
    t.float    "cost"
    t.integer  "component_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labor_cost_lines", :force => true do |t|
    t.float    "hours"
    t.integer  "labor_set_id"
    t.integer  "laborer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labor_costs", :force => true do |t|
    t.date     "date"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "laborers", :force => true do |t|
    t.string   "name"
    t.float    "bill_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_cost_lines", :force => true do |t|
    t.string   "name"
    t.float    "quantity"
    t.integer  "material_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_costs", :force => true do |t|
    t.date     "date"
    t.float    "amount"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.float    "value"
    t.string   "unit"
    t.float    "drop"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relative_deadlines", :force => true do |t|
    t.string   "name"
    t.integer  "interval"
    t.integer  "parent_deadline_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.integer  "contract_id"
    t.integer  "deadline_id"
    t.string   "deadline_type"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unit_cost_estimates", :force => true do |t|
    t.string   "name"
    t.float    "unit_cost"
    t.float    "tax"
    t.integer  "component_id"
    t.integer  "quantity_id"
    t.string   "quantity_type"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
