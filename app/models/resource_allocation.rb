class ResourceAllocation < ActiveRecord::Base
  belongs_to :resource_request
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration, :resource_request
  
  before_save :get_resource
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
end
