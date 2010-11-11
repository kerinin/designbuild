class ComponentsTags < ActiveRecord::Migration
  def self.up
    create_table :components_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :component_id
    end
  end

  def self.down
    drop_table :components_tags
  end
end
