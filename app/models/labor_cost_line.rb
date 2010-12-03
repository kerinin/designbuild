class LaborCostLine < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :labor_set, :class_name => "LaborCost"
  belongs_to :laborer
  
  has_one :task, :through => :labor_set
  
  validates_presence_of :labor_set, :laborer, :hours
  
  validates_numericality_of :hours
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :by_project, lambda {|project| joins(:labor_set => :task).where('tasks.project_id == ?', project.id) } 
  
  def total_markup
    self.labor_set.total_markup unless self.labor_set.blank?
  end
  
  # cost
  marks_up :raw_cost
  
  def raw_cost
    self.hours * self.laborer.bill_rate unless ( self.laborer.blank? || self.laborer.destroyed? )
  end

  def cascade_cache_values
    self.labor_set.save!
  end
end
