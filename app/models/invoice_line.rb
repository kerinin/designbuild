class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice, :inverse_of => :lines #, :autosave => true
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :invoice, :cost
  #validates_associated :invoice
  validates_numericality_of :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage
  
  #after_create Proc.new {|invline| invline.invoice.reload.save! }
  #before_create :set_defaults
  
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
  
  def set_default_invoiced(sym)
    if self.cost.instance_of? Contract
      if self.invoice.project.fixed_bid
        cost = multiply_or_nil 0.5 * self.cost.percent_complete_float, self.cost.estimated_cost
      else
        cost = multiply_or_nil 0.5, self.cost.cost
      end
    else
      if self.invoice.project.fixed_bid
        # determine % of estimated
        cost = multiply_or_nil self.cost.send("#{sym.to_s}_percent_float") * self.cost.percent_complete_float, self.cost.estimated_cost
      else
        # determine costs
        cost = self.cost.send("#{sym.to_s}_cost")
      end
    end
    cost ||= 0
    
    # remove retainage and previously invoiced
    cost *= (1-self.invoice.project.send("#{sym.to_s}_percent_retainage_float")) unless self.invoice.project.send("#{sym.to_s}_percent_retainage_float").nil?
    self.send("#{sym.to_s}_invoiced=", cost - (self.cost.send("#{sym.to_s}_invoiced") || 0) )
    self
  end
  
  def set_default_retainage(sym)
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

    self.send("#{sym.to_s}_retainage=", calculate_retainage( 
      add_or_nil( self.send("#{sym.to_s}_invoiced"), self.cost.send("#{sym.to_s}_invoiced")), 
      self.invoice.project.send("#{sym.to_s}_percent_retainage_float"), 
      self.cost.send("#{sym.to_s}_retainage") || 0
    ) )
    self
  end
  
  def set_defaults
    self.set_default_invoiced(:labor)
    self.set_default_invoiced(:material) 
    
    # Sanity check - moves negative costs to other side if that would result in both being > 0
    if self.labor_invoiced < 0 && self.material_invoiced > -self.labor_invoiced
      self.material_invoiced += self.labor_invoiced
      self.labor_invoiced = 0
    elsif self.material_invoiced < 0 && self.labor_invoiced > -self.material_invoiced
      self.labor_invoiced += self.material_invoiced
      self.material_invoiced = 0
    end
  
    self.set_default_retainage(:labor)
    self.set_default_retainage(:material) 
    self
  end

  def calculate_retainage( invoiced, retainage_float, retainage)
    ( invoiced * retainage_float / ( 1 - retainage_float ) ) - retainage
  end
end

