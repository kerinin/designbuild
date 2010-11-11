class Quantity < ActiveRecord::Base
  belongs_to :component
  
  validates_presence_of :component
end
