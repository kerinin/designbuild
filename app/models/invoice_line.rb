class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice
  belongs_to :component
  
  validates_presence_of :invoice, :component
  
  after_validation :set_defaults
  
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
    subtract_or_nil self.component.invoiced, self.component.paid
  end
  
  protected
  
  def set_defaults
    if self.invoice.project.fixed_bid
      # determine cost as percentage of estimated
      unless !self.labor_invoiced.nil? || self.component.labor_cost.nil?
        (self.component.fixed_cost_estimates.assigned + self.component.unit_cost_estimates.assigned).inject(nil) do |memo,obj|
          labor_cost = add_or_nil memo, multiply_or_nil(obj.task.labor_percent * obj.task.percent_complete, obj.estimated_cost)
        end
      end
      unless !self.material_invoiced.nil? || self.component.material_cost.nil?
        (self.component.fixed_cost_estimates.assigned + self.component.unit_cost_estimates.assigned).inject(nil) do |memo,obj|
          material_cost = add_or_nil memo, multiply_or_nil(obj.task.material_percent * obj.task.percent_complete, obj.estimated_cost)
        end
      end
      unless !self.contract_invoiced.nil?
        divide_or_nil( self.component.contracts.inject(nil) do |memo,obj|
          contract_cost = add_or_nil memo, obj.invoiced
        end, self.component.estimated_contract_cost )
      end      
    else
      # determine cost as total cost to date
      unless !self.labor_invoiced.nil? || self.component.labor_cost.nil?
        labor_cost = self.component.labor_cost
      end
      unless !self.material_invoiced.nil? || self.component.material_cost.nil?
        material_cost = self.component.material_cost
      end
      unless !self.contract_invoiced.nil? || self.component.contract_cost.nil?
        contract_cost = self.component.contract_cost
      end
    end
    
    # remove retainage and previously invoiced
    unless labor_cost.nil?
      labor_cost *= (1-self.invoice.project.labor_percent_retainage_float) unless self.invoice.project.labor_percent_retainage_float.nil?
      self.labor_invoiced = labor_cost - self.component.labor_invoiced
    end
    unless material_cost.nil?
      material_cost *= (1-self.invoice.project.material_percent_retainage_float) unless self.invoice.project.material_percent_retainage_float.nil?
      self.material_invoiced = material_cost - self.component.material_invoiced
    end
    unless contract_cost.nil?
      contract_cost *= (1-self.invoice.project.contract_percent_retainage_float) unless self.invoice.project.contract_percent_retainage_float.nil?
      self.contract_invoiced = contract_cost - self.component.contract_invoiced
    end
  
    # cost * (1-%) - prev = invoiced
    # cost = ( invoiced + prev ) / (1-%)
    # cost * % - prev_ret = retained
    # cost = (retained + prev_ret) / %
    # (retained + prev_ret) / % = (invoiced + prev) / (1-%)
    # retained + prev_ret = (invoiced + prev) * % / (1-%)
    # retained = ( (invoiced + prev) * % / (1-%) ) - prev_ret
  
    unless !self.labor_retainage.nil? || self.invoice.project.labor_percent_retainage_float.nil? || self.labor_invoiced.nil?
      self.labor_retainage = ( (self.labor_invoiced + self.component.labor_invoiced) * self.invoice.project.labor_percent_retainage_float / ( 1 - self.invoice.project.labor_percent_retainage_float ) ) - self.component.labor_retainage
    end
    unless !self.material_retainage.nil? || self.invoice.project.material_percent_retainage_float.nil? || self.material_invoiced.nil?
      self.material_retainage = ( (self.material_invoiced + self.component.material_invoiced) * self.invoice.project.material_percent_retainage_float / ( 1 - self.invoice.project.material_percent_retainage_float ) ) - self.component.material_retainage
    end
    unless !self.contract_retainage.nil? || self.invoice.project.contract_percent_retainage_float.nil? || self.contract_invoiced.nil? 
      self.contract_retainage = ( (self.contract_invoiced + self.component.contract_invoiced) * self.invoice.project.contract_percent_retainage_float / ( 1 - self.invoice.project.contract_percent_retainage_float ) ) - self.component.contract_retainage
    end
  end
end

