class LaborCost < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail
  
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  before_save :cache_values
  
  after_save :deactivate_task_if_done
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  def total_markup
    self.task.total_markup unless self.task.blank?
  end
  
  marks_up :raw_cost
  #def cost
  #  multiply_or_nil self.raw_cost, (1+(self.task.total_markup/100))
  #end
  
  # raw_cost
  
  def cache_values
    self.line_items.reload
    
    self.cache_raw_cost
  end
  
  def cascade_cache_values
    self.task.save!
  end

  protected
    
  def cache_raw_cost
    self.raw_cost = self.line_items.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def deactivate_task_if_done
    self.task.active = false if self.percent_complete >= 100
    self.task.save!
  end
end
