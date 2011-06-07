class ResourceRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  
  has_and_belongs_to_many :resources
  
  has_many :resource_allocations
  
  default_scope :order => :updated_at
  
  validates_presence_of :project
end


