class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice, :inverse_of => :lines #, :autosave => true
  belongs_to :component, :inverse_of => :invoice_lines
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :invoice, :component
  validates_numericality_of :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage
  
  def invoiced
    self.labor_invoiced + self.material_invoiced
  end
  
  def retainage
    self.labor_retainage + self.material_retainage
  end
  
  def invoiced=(value)
    # allows quick setting of invoiced - divides evenly
    self.labor_invoiced = value / 2
    self.material_invoiced = value / 2
  end
  
  def retainage_as_expected?
    # I think this is required because we can't do polymorphic inverse_of
    # As such, the cost's labor_retainage doesn't get updated (on self's cached version)
    # if another invoice line is changed
    self.cost.reload
    expected_labor = calculate_retainage( 
      self.labor_invoiced + self.cost.labor_invoiced, 
      self.invoice.project.labor_percent_retainage_float, 
      self.cost.labor_retainage 
    )

    expected_material = calculate_retainage( 
      self.material_invoiced + self.cost.material_invoiced, 
      self.invoice.project.material_percent_retainage_float, 
      self.cost.material_retainage 
    )
    
    expected_labor.round(2) == self.labor_retainage.round(2) && expected_material.round(2) == self.material_retainage.round(2)
  end
  
  def calculate_retainage( invoiced, retainage_float, retainage)
    ( invoiced * retainage_float / ( 1 - retainage_float ) ) - retainage
  end
end

