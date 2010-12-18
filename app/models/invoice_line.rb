class InvoiceLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :invoice
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :invoice, :cost
  validates_associated :invoice
  validates_numericality_of :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage
  
  before_validation :set_defaults
  after_update Proc.new {|invline| invline.invoice.save! }
  
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
  
  protected
  
  def set_defaults
    if self.cost.instance_of? Contract
      if self.invoice.project.fixed_bid
        labor_cost = 0.5 * self.cost.percent_complete_float * self.cost.estimated_cost if self.labor_invoiced.nil?
        material_cost = 0.5 * self.cost.percent_complete_float * self.cost.estimated_cost if self.material_invoiced.nil?
      else
        labor_cost = 0.5 * self.cost.cost if self.labor_invoiced.nil?
        material_cost = 0.5 * self.cost.cost if self.labor_invoiced.nil?
      end
    else
      if self.invoice.project.fixed_bid
        # determine % of estimated
        labor_cost = self.cost.labor_percent_float * self.cost.percent_complete_float * self.cost.estimated_cost if self.labor_invoiced.nil?
        material_cost = self.cost.material_percent_float * self.cost.percent_complete_float * self.cost.estimated_cost if self.material_invoiced.nil?
      else
        # determine costs
        labor_cost = self.cost.labor_cost if self.labor_invoiced.nil?
        material_cost = self.cost.material_cost if self.material_invoiced.nil?
      end
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
      self.labor_retainage = calculate_retainage( 
        self.labor_invoiced + self.cost.labor_invoiced, 
        self.invoice.project.labor_percent_retainage_float, 
        self.cost.labor_retainage 
      )
    end
    unless !self.material_retainage.nil? || self.invoice.project.material_percent_retainage_float.nil? || self.material_invoiced.nil?
      self.material_retainage = calculate_retainage( 
        self.material_invoiced + self.cost.material_invoiced, 
        self.invoice.project.material_percent_retainage_float, 
        self.cost.material_retainage 
      )
    end
  end
  
  def calculate_retainage( invoiced, retainage_float, retainage)
    ( invoiced * retainage_float / ( 1 - retainage_float ) ) - retainage
  end
end

