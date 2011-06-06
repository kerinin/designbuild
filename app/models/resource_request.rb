class ResourceRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  belongs_to :resource
  
  has_many :resource_allocations
  
  default_scope :order => :updated_at
end


