class CreateInvoiceLines < ActiveRecord::Migration
  def self.up
    create_table :invoice_lines do |t|
      t.float :labor_invoiced
      t.float :labor_retainage
      t.float :labor_paid
      t.float :labor_retained
      
      t.float :material_invoiced
      t.float :material_retainage
      t.float :material_paid
      t.float :material_retained

      t.string :comment
      
      t.belongs_to :invoice
      t.belongs_to :cost, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_lines
  end
end
