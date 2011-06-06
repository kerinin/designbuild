class ResourceAllocation < ActiveRecord::Base
  belongs_to :request
  
  default_scope :order => :start_date
end
