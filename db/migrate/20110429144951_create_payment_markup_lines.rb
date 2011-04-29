class CreatePaymentMarkupLines < ActiveRecord::Migration
  def self.up
    create_table :payment_markup_lines do |t|
      t.belongs_to :invoice
      t.belongs_to :markup
      
      t.string :comment
      
      t.float :labor_paid, :default => 0
      t.float :labor_retained, :default => 0
      t.float :material_paid, :default => 0
      t.float :material_retained, :default => 0
      t.float :paid, :default => 0
      t.float :retained, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_markup_lines
  end
end
