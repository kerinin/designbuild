class CreatePaymentLines < ActiveRecord::Migration
  def self.up
    create_table :payment_lines do |t|
      t.float :labor_paid
      t.float :labor_retained
      
      t.float :material_paid
      t.float :material_retained
      
      t.string :comment
      
      t.belongs_to :payment
      t.belongs_to :cost, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_lines
  end
end
