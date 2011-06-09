class ResourceAllocation < ActiveRecord::Base
  belongs_to :resource_request
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration, :resource_request
  
  #after_save :create_event, :on => :create
  #after_save :update_event, :except => :create
  after_save :update_request
  before_save :get_resource
  #after_destroy :update_request, :delete_event
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
  
  def update_request
    self.resource_request.save!
  end
  
  def create_event
  end
  
  def update_event
  end
  
  def delete_event
  end
end
