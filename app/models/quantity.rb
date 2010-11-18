class Quantity < ActiveRecord::Base
  belongs_to :component
  
  has_many :unit_cost_estimates, :dependent => :destroy
  
  validates_presence_of :name, :component, :value
  validates_numericality_of :value
  
  
  def optgroup_label
    "#{self.name} (#{self.value} #{self.unit})"
  end
end
