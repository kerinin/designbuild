class CreatePaymentMarkupLines < ActiveRecord::Migration
  def self.up
    create_table :payment_markup_lines do |t|
      belongs_to :invoice
      belongs_to :markup
      
      t.comment :string
      
      t.labor_paid :float, :default => 0
      t.labor_retained :float, :default => 0
      t.material_paid :float, :default => 0
      t.material_retained :float, :default => 0
      t.paid :float, :default => 0
      t.retained :float, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_markup_lines
  end
end
