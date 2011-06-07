class AddHabtmResourceResourceRequest < ActiveRecord::Migration
  def self.up
    create_table :resource_requests_resources, :id => false do |t|
      t.belongs_to :resource
      t.belongs_to :resource_request
    end
  end

  def self.down
    drop_table :resource_requests_resources
  end
end
