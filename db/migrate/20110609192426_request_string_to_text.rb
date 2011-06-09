class RequestStringToText < ActiveRecord::Migration
  def self.up
    change_table :resource_requests do |t|
      t.change :comment, :text
    end
  end

  def self.down
    change_table :resource_requests do |t|
      t.change :comment, :string
    end
  end
end
