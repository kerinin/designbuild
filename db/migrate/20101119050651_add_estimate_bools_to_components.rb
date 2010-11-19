class AddEstimateBoolsToComponents < ActiveRecord::Migration
  def self.up
    add_column :components, :expand_in_estimate, :boolean
    add_column :components, :show_costs_in_estimate, :boolean
  end

  def self.down
    remove_column :components, :expand_in_estimate
    remove_column :components, :show_costs_in_estimate
  end
end
