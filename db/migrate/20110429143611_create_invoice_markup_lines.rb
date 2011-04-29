class CreateInvoiceMarkupLines < ActiveRecord::Migration
  def self.up
    create_table :invoice_markup_lines do |t|
      t.belongs_to :invoice
      t.belongs_to :markup
      
      t.string :comment
            
      t.float :labor_invoiced, :default => 0
      t.float :labor_retainage, :default => 0
      t.float :material_invoiced, :default => 0
      t.float :material_retainage, :default => 0
      t.float :invoiced, :default => 0
      t.float :retainage, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_markup_lines
  end
end
