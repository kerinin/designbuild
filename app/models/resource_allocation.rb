class ResourceAllocation < ActiveRecord::Base
  belongs_to :resource_request
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration, :resource_request
  
  after_save :update_request
  before_save :get_resource
  after_destroy :update_request
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
  
  def update_request
    self.resource_request.save!
  end
end
