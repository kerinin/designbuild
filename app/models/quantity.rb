class Quantity < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :component, :inverse_of => :quantities
  
  has_many :unit_cost_estimates, :dependent => :destroy
  
  validates_presence_of :name, :component, :value
  validates_numericality_of :value
  
  after_save :cascade_cache_values, :if => proc {|i| i.value_changed? }
  after_destroy :cascade_cache_values
  
  def optgroup_label
    "#{self.name} (#{self.value} #{self.unit})"
  end

  def cascade_cache_values
    self.unit_cost_estimates(true).all.each {|uc| uc.save!}
  end
end
