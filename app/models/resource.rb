class Resource < ActiveRecord::Base
  has_many :resource_requests, :dependent => :destroy
  has_many :resource_allocations, :dependent => :destroy
  
  default_scope :order => :name
  
  validates_presence_of :name
  
  # before_save :create_calendar, :if => proc {|r| r.calendar_id.nil?}
  
  def create_calendar
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    
    cal = Calendar.new(service)
    self.calendar_id = cal.id
  end
end