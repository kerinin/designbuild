class ResourceAllocation < ActiveRecord::Base
  belongs_to :resource_request
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration, :resource_request
end
