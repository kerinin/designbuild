class CreateInvoiceMarkupLines < ActiveRecord::Migration
  def self.up
    create_table :invoice_markup_lines do |t|
      belongs_to :invoice
      belongs_to :markup
      
      t.comment :string
            
      t.labor_invoiced :float, :default => 0
      t.labor_retainage :float, :default => 0
      t.material_invoiced :float, :default => 0
      t.material_retainage :float, :default => 0
      t.invoiced :float, :default => 0
      t.retainage :float, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_markup_lines
  end
end
