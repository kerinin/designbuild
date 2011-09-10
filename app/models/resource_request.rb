class ResourceRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  belongs_to :resource
  
  has_many :resource_allocations, :dependent => :destroy
  
  default_scope :order => 'resource_requests.updated_at'
  
  validates_presence_of :project, :duration, :resource
  
  scope :active, lambda { includes(:resource_allocations).where('(SELECT SUM(resource_allocations.duration)) < resource_requests.duration') }
  
  accepts_nested_attributes_for :resource_allocations
  
  def allocated
    self.resource_allocations.sum(:duration)
  end
  
  def remaining
    self.allocated > self.duration ? 0 : self.duration - self.allocated
  end
end


