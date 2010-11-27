class Quantity < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :component
  
  has_many :unit_cost_estimates, :dependent => :destroy
  
  validates_presence_of :name, :component, :value
  validates_numericality_of :value
  
  after_save :cache_values
  after_destroy :cache_values
  
  def optgroup_label
    "#{self.name} (#{self.value} #{self.unit})"
  end
  
  private
  
  def cache_values
    self.unit_cost_estimates.all.each {|uc| uc.cache_values}
  end
end
