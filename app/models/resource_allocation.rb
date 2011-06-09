class ResourceAllocation < ActiveRecord::Base
  belongs_to :resource_request
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration, :resource_request
  
  before_save :create_event, :if => proc {|i| i.event_id.nil?}
  #after_update :update_event
  after_save :update_request
  before_save :get_resource
  after_destroy :update_request #, :delete_event
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
  
  def update_request
    self.resource_request.save!
  end
  
  def create_event
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    
    calendar = GCal4Ruby::Calendar.find(service, {:id => self.resource.calendar_id})
    event = GCal4Ruby::Event.new(service, {
      :calendar => calendar, 
      :title => self.resource_request.task.blank? ? self.resource_request.project.name : self.resource_request.task.name, 
      :start_time => self.start_date, 
      :end_time => self.start_date,
      :where => self.resource_request.project.name,
      :all_day => true,
      :content => self.resource_request.comment
    })
    event.save
    self.event_id = event.id
  end
  
  def update_event
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
        
    event = GCal4Ruby::Event.find(service, {:id => self.event_id})
    event.title = self.resource_request.task.blank? ? self.resource_request.project.name : self.resource_request.task.name
    event.save
  end
  
  def delete_event
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
        
    event = GCal4Ruby::Event.find(service, {:id => self.event_id})
    event.delete
  end
end
