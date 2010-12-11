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

ActiveRecord::Schema.define(:version => 20101211155214) do

  create_table "bids", :force => true do |t|
    t.string   "contractor"
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "expand_in_estimate"
    t.boolean  "show_costs_in_estimate"
    t.float    "estimated_fixed_cost"
    t.float    "estimated_unit_cost"
    t.float    "estimated_raw_fixed_cost"
    t.float    "estimated_raw_unit_cost"
    t.float    "total_markup"
    t.integer  "position"
    t.float    "estimated_contract_cost"
    t.float    "estimated_raw_contract_cost"
  end

  add_index "components", ["ancestry"], :name => "index_components_on_ancestry"

  create_table "components_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "component_id"
  end

  create_table "contract_costs", :force => true do |t|
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bid_id"
    t.float    "raw_cost"
    t.float    "raw_invoiced"
    t.float    "total_markup"
    t.integer  "position"
    t.integer  "component_id"
  end

  create_table "deadlines", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "interval"
    t.integer  "parent_deadline_id"
    t.date     "date_completed"
  end

  create_table "fixed_cost_estimates", :force => true do |t|
    t.string   "name"
    t.float    "raw_cost"
    t.integer  "component_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_lines", :force => true do |t|
    t.float    "labor_invoiced"
    t.float    "labor_retainage"
    t.float    "labor_paid"
    t.float    "labor_retained"
    t.float    "material_invoiced"
    t.float    "material_retainage"
    t.float    "material_paid"
    t.float    "material_retained"
    t.string   "comment"
    t.integer  "invoice_id"
    t.integer  "cost_id"
    t.string   "cost_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.date     "date"
    t.string   "state"
    t.string   "template"
    t.integer  "project_id"
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
    t.float    "percent_complete"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "raw_cost"
    t.string   "note"
  end

  create_table "laborers", :force => true do |t|
    t.string   "name"
    t.float    "bill_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "pay_rate"
  end

  create_table "markings", :force => true do |t|
    t.integer  "markupable_id"
    t.string   "markupable_type"
    t.integer  "markup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "markups", :force => true do |t|
    t.string   "name"
    t.float    "percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_cost_lines", :force => true do |t|
    t.string   "name"
    t.string   "quantity"
    t.integer  "material_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_costs", :force => true do |t|
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "task_id"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestones", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "interval"
    t.date     "date_completed"
    t.integer  "task_id"
    t.integer  "project_id"
    t.integer  "parent_date_id"
    t.string   "parent_date_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "estimated_fixed_cost"
    t.float    "estimated_raw_fixed_cost"
    t.float    "estimated_unit_cost"
    t.float    "estimated_raw_unit_cost"
    t.float    "estimated_contract_cost"
    t.float    "estimated_raw_contract_cost"
    t.float    "material_cost"
    t.float    "raw_material_cost"
    t.float    "labor_cost"
    t.float    "raw_labor_cost"
    t.float    "contract_cost"
    t.float    "raw_contract_cost"
    t.float    "contract_invoiced"
    t.float    "raw_contract_invoiced"
    t.float    "projected_cost"
    t.float    "raw_projected_cost"
    t.boolean  "show_planning",               :default => true
    t.boolean  "show_construction",           :default => false
    t.float    "labor_percent_retainage"
    t.float    "material_percent_retainage"
    t.boolean  "fixed_bid",                   :default => false
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.float    "value"
    t.string   "unit"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
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
    t.boolean  "active"
    t.integer  "contract_id"
    t.integer  "deadline_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "estimated_raw_unit_cost"
    t.float    "estimated_raw_fixed_cost"
    t.float    "raw_labor_cost"
    t.float    "raw_material_cost"
    t.float    "total_markup"
    t.float    "percent_complete",         :default => 0.0, :null => false
  end

  create_table "unit_cost_estimates", :force => true do |t|
    t.string   "name"
    t.float    "unit_cost"
    t.integer  "component_id"
    t.integer  "quantity_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "drop"
    t.float    "raw_cost"
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

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
