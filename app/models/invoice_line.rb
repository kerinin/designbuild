class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice
  belongs_to :component
  
  validates_presence_of :invoice, :component
  
  def invoiced
    add_or_nil self.labor_invoiced, add_or_nil( self.material_invoiced, self.contract_invoiced)
  end
  
  def retainage
    add_or_nil self.labor_retainage, add_or_nil( self.material_retainage, self.contract_retainage )
  end
  
  def paid
    add_or_nil self.labor_paid, add_or_nil( self.material_paid, self.contract_paid )
  end
  
  def retained
    add_or_nil self.labor_retained, add_or_nil( self.material_retained, self.contract_retained )
  end
  
  def outstanding
  end
end
