class ResourceRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  belongs_to :resource
  
  has_many :resource_allocations, :dependent => :destroy
  
  default_scope :order => :updated_at
  
  validates_presence_of :project, :duration, :resource
  
  before_save :update_totals
  
  scope :active, lambda { where( 'remaining > 0' ) }
  
  private
  
  def update_totals
    self.allocated = self.resource_allocations.sum(:duration)
    self.remaining = self.allocated > self.duration ? 0 : self.duration - self.allocated
  end
end


