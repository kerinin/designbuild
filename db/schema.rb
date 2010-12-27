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

ActiveRecord::Schema.define(:version => 20101227171224) do

  create_table "bids", :force => true do |t|
    t.string   "contractor"
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost"
  end

  add_index "bids", ["contract_id"], :name => "index_bids_on_contract_id"

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
    t.float    "estimated_component_fixed_cost"
    t.float    "estimated_raw_component_fixed_cost"
    t.float    "estimated_subcomponent_fixed_cost"
    t.float    "estimated_raw_subcomponent_fixed_cost"
    t.float    "estimated_component_unit_cost"
    t.float    "estimated_raw_component_unit_cost"
    t.float    "estimated_subcomponent_unit_cost"
    t.float    "estimated_raw_subcomponent_unit_cost"
    t.float    "estimated_component_contract_cost"
    t.float    "estimated_raw_component_contract_cost"
    t.float    "estimated_subcomponent_contract_cost"
    t.float    "estimated_raw_subcomponent_contract_cost"
    t.float    "estimated_component_cost"
    t.float    "estimated_raw_component_cost"
    t.float    "estimated_subcomponent_cost"
    t.float    "estimated_raw_subcomponent_cost"
    t.float    "estimated_cost"
    t.float    "estimated_raw_cost"
  end

  add_index "components", ["ancestry"], :name => "index_components_on_ancestry"
  add_index "components", ["project_id"], :name => "index_components_on_project_id"

  create_table "components_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "component_id"
  end

  add_index "components_tags", ["component_id"], :name => "index_components_tags_on_component_id"
  add_index "components_tags", ["tag_id"], :name => "index_components_tags_on_tag_id"

  create_table "contract_costs", :force => true do |t|
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost"
  end

  add_index "contract_costs", ["contract_id"], :name => "index_contract_costs_on_contract_id"

  create_table "contracts", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bid_id"
    t.float    "estimated_raw_cost"
    t.float    "raw_cost"
    t.float    "total_markup"
    t.integer  "position"
    t.integer  "component_id"
    t.float    "estimated_cost"
    t.float    "cost"
  end

  add_index "contracts", ["component_id"], :name => "index_contracts_on_component_id"
  add_index "contracts", ["project_id"], :name => "index_contracts_on_project_id"

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

  add_index "deadlines", ["parent_deadline_id"], :name => "index_deadlines_on_parent_deadline_id"
  add_index "deadlines", ["project_id"], :name => "index_deadlines_on_project_id"

  create_table "fixed_cost_estimates", :force => true do |t|
    t.string   "name"
    t.float    "raw_cost"
    t.integer  "component_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost"
  end

  add_index "fixed_cost_estimates", ["component_id"], :name => "index_fixed_cost_estimates_on_component_id"
  add_index "fixed_cost_estimates", ["task_id"], :name => "index_fixed_cost_estimates_on_task_id"

  create_table "invoice_lines", :force => true do |t|
    t.float    "labor_invoiced",     :default => 0.0, :null => false
    t.float    "labor_retainage",    :default => 0.0, :null => false
    t.float    "material_invoiced",  :default => 0.0, :null => false
    t.float    "material_retainage", :default => 0.0, :null => false
    t.string   "comment"
    t.integer  "invoice_id"
    t.integer  "cost_id"
    t.string   "cost_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_lines", ["invoice_id"], :name => "index_invoice_lines_on_invoice_id"

  create_table "invoices", :force => true do |t|
    t.date     "date"
    t.string   "state"
    t.string   "template"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "invoices", ["project_id"], :name => "index_invoices_on_project_id"

  create_table "labor_cost_lines", :force => true do |t|
    t.float    "hours"
    t.integer  "labor_set_id"
    t.integer  "laborer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost"
    t.float    "raw_cost"
    t.float    "laborer_pay"
    t.integer  "project_id"
  end

  add_index "labor_cost_lines", ["labor_set_id"], :name => "index_labor_cost_lines_on_labor_set_id"
  add_index "labor_cost_lines", ["project_id"], :name => "index_labor_cost_lines_on_project_id"

  create_table "labor_costs", :force => true do |t|
    t.date     "date"
    t.float    "percent_complete"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "raw_cost"
    t.string   "note"
    t.integer  "project_id"
    t.float    "cost"
  end

  add_index "labor_costs", ["project_id"], :name => "index_labor_costs_on_project_id"

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

  add_index "markings", ["markup_id"], :name => "index_markings_on_markup_id"
  add_index "markings", ["markupable_id"], :name => "index_markings_on_markupable_id"
  add_index "markings", ["markupable_type"], :name => "index_markings_on_markupable_type"

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

  add_index "material_cost_lines", ["material_set_id"], :name => "index_material_cost_lines_on_material_set_id"

  create_table "material_costs", :force => true do |t|
    t.date     "date"
    t.float    "raw_cost"
    t.integer  "task_id"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost"
  end

  add_index "material_costs", ["supplier_id"], :name => "index_material_costs_on_supplier_id"
  add_index "material_costs", ["task_id"], :name => "index_material_costs_on_task_id"

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

  add_index "milestones", ["parent_date_id"], :name => "index_milestones_on_parent_date_id"
  add_index "milestones", ["parent_date_type"], :name => "index_milestones_on_parent_date_type"
  add_index "milestones", ["project_id"], :name => "index_milestones_on_project_id"
  add_index "milestones", ["task_id"], :name => "index_milestones_on_task_id"

  create_table "payment_lines", :force => true do |t|
    t.float    "labor_paid",        :default => 0.0, :null => false
    t.float    "labor_retained",    :default => 0.0, :null => false
    t.float    "material_paid",     :default => 0.0, :null => false
    t.float    "material_retained", :default => 0.0, :null => false
    t.string   "comment"
    t.integer  "payment_id"
    t.integer  "cost_id"
    t.string   "cost_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_lines", ["cost_id"], :name => "index_payment_lines_on_cost_id"
  add_index "payment_lines", ["payment_id"], :name => "index_payment_lines_on_payment_id"

  create_table "payments", :force => true do |t|
    t.date     "date"
    t.string   "state"
    t.float    "paid"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "retained"
  end

  add_index "payments", ["project_id"], :name => "index_payments_on_project_id"

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
    t.float    "projected_cost"
    t.float    "raw_projected_cost"
    t.boolean  "show_planning",               :default => true
    t.boolean  "show_construction",           :default => false
    t.float    "labor_percent_retainage",     :default => 0.0,   :null => false
    t.float    "material_percent_retainage",  :default => 0.0,   :null => false
    t.boolean  "fixed_bid",                   :default => false
    t.float    "estimated_cost"
    t.float    "estimated_raw_cost"
    t.float    "cost"
    t.float    "raw_cost"
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id"], :name => "index_projects_users_on_project_id"
  add_index "projects_users", ["user_id"], :name => "index_projects_users_on_user_id"

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.float    "value"
    t.string   "unit"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quantities", ["component_id"], :name => "index_quantities_on_component_id"

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
    t.float    "percent_complete",                  :default => 0.0, :null => false
    t.float    "estimated_unit_cost"
    t.float    "estimated_fixed_cost"
    t.float    "estimated_cost"
    t.float    "estimated_raw_cost"
    t.float    "component_estimated_unit_cost"
    t.float    "component_estimated_raw_unit_cost"
    t.float    "component_estimated_cost"
    t.float    "component_estimated_raw_cost"
    t.float    "labor_cost"
    t.float    "material_cost"
    t.float    "cost"
    t.float    "raw_cost"
    t.float    "projected_cost"
    t.float    "raw_projected_cost"
  end

  add_index "tasks", ["contract_id"], :name => "index_tasks_on_contract_id"
  add_index "tasks", ["deadline_id"], :name => "index_tasks_on_deadline_id"
  add_index "tasks", ["project_id"], :name => "index_tasks_on_project_id"

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
    t.float    "cost"
  end

  add_index "unit_cost_estimates", ["component_id"], :name => "index_unit_cost_estimates_on_component_id"
  add_index "unit_cost_estimates", ["task_id"], :name => "index_unit_cost_estimates_on_task_id"

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

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
