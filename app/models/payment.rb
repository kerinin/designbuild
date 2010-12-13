class Payment < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'PaymentLine'
  
  validates_presence_of :project
end
