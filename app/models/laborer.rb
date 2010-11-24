class Laborer < ActiveRecord::Base
  belongs_to :project
  
  has_many :labor_cost_lines, :dependent => :destroy
  
  validates_presence_of :project, :bill_rate
  
  validates_numericality_of :bill_rate
end
