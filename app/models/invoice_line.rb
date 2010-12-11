class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :invoice, :cost
  
  after_validation :set_defaults
  
  def invoiced
    add_or_nil self.labor_invoiced, self.material_invoiced
  end
  
  def retainage
    add_or_nil self.labor_retainage, self.material_retainage
  end
  
  def paid
    add_or_nil self.labor_paid, self.material_paid
  end
  
  def retained
    add_or_nil self.labor_retained, self.material_retained
  end
  
  def outstanding
    subtract_or_nil self.cost.invoiced, self.cost.paid
  end
  
  protected
  
  def set_defaults
    if self.invoice.project.fixed_bid
      labor_cost = self.cost.labor_percent * self.cost.percent_complete * self.cost.estimated_cost if self.labor_invoiced.nil?
      material_cost = self.cost.material_percent * self.cost.percent_complete * self.cost.estimated_cost if self.material_invoiced.nil?
    else
      labor_cost = self.cost.labor_cost if self.labor_invoiced.nil?
      material_cost = self.cost.material_cost if self.material_invoiced.nil?
    end
    
    # remove retainage and previously invoiced
    unless labor_cost.nil?
      labor_cost *= (1-self.invoice.project.labor_percent_retainage_float) unless self.invoice.project.labor_percent_retainage_float.nil?
      self.labor_invoiced = labor_cost - self.cost.labor_invoiced
    end
    unless material_cost.nil?
      material_cost *= (1-self.invoice.project.material_percent_retainage_float) unless self.invoice.project.material_percent_retainage_float.nil?
      self.material_invoiced = material_cost - self.cost.material_invoiced
    end
  
    # cost * (1-%) - prev = invoiced
    # cost = ( invoiced + prev ) / (1-%)
    # cost * % - prev_ret = retained
    # cost = (retained + prev_ret) / %
    # (retained + prev_ret) / % = (invoiced + prev) / (1-%)
    # retained + prev_ret = (invoiced + prev) * % / (1-%)
    # retained = ( (invoiced + prev) * % / (1-%) ) - prev_ret
  
    unless !self.labor_retainage.nil? || self.invoice.project.labor_percent_retainage_float.nil? || self.labor_invoiced.nil?
      self.labor_retainage = ( (self.labor_invoiced + self.cost.labor_invoiced) * self.invoice.project.labor_percent_retainage_float / ( 1 - self.invoice.project.labor_percent_retainage_float ) ) - self.cost.labor_retainage
    end
    unless !self.material_retainage.nil? || self.invoice.project.material_percent_retainage_float.nil? || self.material_invoiced.nil?
      self.material_retainage = ( (self.material_invoiced + self.cost.material_invoiced) * self.invoice.project.material_percent_retainage_float / ( 1 - self.invoice.project.material_percent_retainage_float ) ) - self.cost.material_retainage
    end
  end
end

