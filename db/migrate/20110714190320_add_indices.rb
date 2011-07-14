class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :bids, :date
    
    add_index :components, :position
    
    add_index :contract_costs, :date
    add_index :contract_costs, :component_id
    
    add_index :contracts, :position
    add_index :contracts, :bid_id
    
    add_index :date_points, [:source_id, :source_type]
    
    add_index :labor_cost_lines, :laborer_id
    
    add_index :labor_costs, :task_id
    add_index :labor_costs, :component_id
    
    add_index :markings, :project_id
    add_index :markings, :component_id
    
    add_index :material_costs, :project_id
    add_index :material_costs, :component_id
    
    add_index :resource_allocations, :start_date
    add_index :resource_allocations, :resource_request_id
    add_index :resource_allocations, :resource_id
    add_index :resource_allocations, :event_id
    
    add_index :resource_requests, :project_id
    add_index :resource_requests, :task_id
    add_index :resource_requests, :resource_id
  end

  def self.down
  end
end
