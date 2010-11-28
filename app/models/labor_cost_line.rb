class LaborCostLine < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :labor_set, :class_name => "LaborCost"
  belongs_to :laborer
  
  validates_presence_of :labor_set, :laborer, :hours
  
  validates_numericality_of :hours
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  marks_up :raw_cost
  #def cost
  #  multiply_or_nil self.raw_cost, (1+(self.labor_set.task.total_markup/100))
  #end
  
  def raw_cost
    self.hours * self.laborer.bill_rate unless self.laborer.blank?
  end

  def cascade_cache_values
    self.labor_set.save!
  end
end
