class Laborer < ActiveRecord::Base
  belongs_to :project
  
  validates_presence_of :project, :bill_rate
  
  validates_numericality_of :bill_rate
end
