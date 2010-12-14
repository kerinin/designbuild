class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :invoice, :cost
  validates_associated :invoice
  
  before_save :set_defaults
  
  def invoiced
    add_or_nil self.labor_invoiced, self.material_invoiced
  end
  
  def retainage
    add_or_nil self.labor_retainage, self.material_retainage
  end
  
  def invoiced=(value)
    # allows quick setting of invoiced - divides evenly
    self.labor_invoiced = value / 2
    self.material_invoiced = value / 2
  end
  
  def retainage_as_expected?
    if self.invoice.project.labor_percent_retainage == 0 || self.labor_invoiced == nil
      expected_labor = nil
    else self.labor_invoiced
      expected_labor = subtract_or_nil( ( ( add_or_nil self.labor_invoiced, self.cost.labor_invoiced) * self.invoice.project.labor_percent_retainage_float / ( 1 - self.invoice.project.labor_percent_retainage_float ) ), self.cost.labor_retainage )
    end

    if self.invoice.project.material_percent_retainage == 0 || self.material_invoiced == nil
      expected_material = nil
    else self.material_invoiced
      expected_material = subtract_or_nil( ( ( add_or_nil self.material_invoiced, self.cost.material_invoiced) * self.invoice.project.material_percent_retainage_float / ( 1 - self.invoice.project.material_percent_retainage_float ) ), self.cost.material_retainage )
    end
    
    # all the same (including nil)
    return true if expected_labor == self.labor_retainage && expected_material == self.material_retainage
    # must be either different or similar floats
    
    # one nil, the other not
    return false if expected_labor.nil? || self.labor_retainage.nil? || expected_material.nil? || self.material_retainage.nil?
    # all values known to be non-nil
    
    # round to pennies & compare
    return true if expected_labor.round(2) == self.labor_retainage.round(2) && expected_material.round(2) == self.material_retainage.round(2)
    
    false
  end
  
  protected
  
  def set_defaults
    if self.invoice.project.fixed_bid
      # determine % of estimated
      labor_cost = self.cost.labor_percent_float * self.cost.percent_complete_float * self.cost.estimated_cost if self.labor_invoiced.nil?
      material_cost = self.cost.material_percent_float * self.cost.percent_complete_float * self.cost.estimated_cost if self.material_invoiced.nil?
    else
      # determine costs
      labor_cost = self.cost.labor_cost if self.labor_invoiced.nil?
      material_cost = self.cost.material_cost if self.material_invoiced.nil?
    end

    # remove retainage and previously invoiced
    unless labor_cost.nil?
      labor_cost *= (1-self.invoice.project.labor_percent_retainage_float) unless self.invoice.project.labor_percent_retainage_float.nil?
      self.labor_invoiced = subtract_or_nil labor_cost, self.cost.labor_invoiced
    end
    unless material_cost.nil?
      material_cost *= (1-self.invoice.project.material_percent_retainage_float) unless self.invoice.project.material_percent_retainage_float.nil?
      self.material_invoiced = subtract_or_nil material_cost, self.cost.material_invoiced
    end
    
    # Sanity check - moves negative costs to other side if that would result in both being > 0
    unless self.labor_invoiced.nil? || self.material_invoiced.nil?
      if self.labor_invoiced < 0 && self.material_invoiced > -self.labor_invoiced
        self.material_invoiced += self.labor_invoiced
        self.labor_invoiced = 0
      elsif self.material_invoiced < 0 && self.labor_invoiced > -self.material_invoiced
        self.labor_invoiced += self.material_invoiced
        self.material_invoiced = 0
      end
    end
  
    # Check my math!
    # cost * (1-%) - prev = invoiced
    # cost = ( invoiced + prev ) / (1-%)
    # cost * % - prev_ret = retained
    # cost = (retained + prev_ret) / %
    # (retained + prev_ret) / % = (invoiced + prev) / (1-%)
    # retained + prev_ret = (invoiced + prev) * % / (1-%)
    # retained = ( (invoiced + prev) * % / (1-%) ) - prev_ret
  
    # calculate retainage based on material costs
    # the math allows retainage to be calculated for arbitrary labor & material values
    unless !self.labor_retainage.nil? || self.invoice.project.labor_percent_retainage_float.nil? || self.labor_invoiced.nil?
      self.labor_retainage = subtract_or_nil( ( ( add_or_nil self.labor_invoiced, self.cost.labor_invoiced) * self.invoice.project.labor_percent_retainage_float / ( 1 - self.invoice.project.labor_percent_retainage_float ) ), self.cost.labor_retainage )
    end
    unless !self.material_retainage.nil? || self.invoice.project.material_percent_retainage_float.nil? || self.material_invoiced.nil?
      self.material_retainage = subtract_or_nil( ( ( add_or_nil self.material_invoiced, self.cost.material_invoiced) * self.invoice.project.material_percent_retainage_float / ( 1 - self.invoice.project.material_percent_retainage_float ) ), self.cost.material_retainage )
    end
  end
end

