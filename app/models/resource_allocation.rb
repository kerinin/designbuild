class ResourceAllocation < ActiveRecord::Base
  attr_accessor :nested
  
  belongs_to :resource_request, :inverse_of => :resource_allocations
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration 
  validates_presence_of :resource_request, :unless => :nested
  
  after_create do |r|
    r.update_attributes :event_id => 'caching'
    r.delay.create_event
  end
  after_update do |r|
    unless r.event_id.nil? || (r.event_id_changed? && ( r.event_id_was.nil? || r.event_id_was == 'caching') )
      r.delay.update_event 
    end
  end
  before_save :get_resource
  before_destroy do |r|
    Delayed::Job.enqueue( DeleteEventJob.new(r.event_id) ) unless r.event_id.nil? || r.event_id == 'caching'
  end
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
  
  def create_event
    puts "Starting create event for resource allocation #{self.id}"
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication Status: #{auth}"
    
    calendar = GCal4Ruby::Calendar.find(service, {:id => self.resource.calendar_id})
    puts "Calendar search result: #{calendar}"
    
    event = GCal4Ruby::Event.new(service, {
      :calendar => calendar, 
      :title => [
        self.resource_request.project.short.nil? ? self.resource_request.project.name : self.resource_request.project.short,
        self.resource_request.task.blank? ? nil : ": #{self.resource_request.task.name}"
      ].join,
      :start_time => self.start_date, 
      :end_time => self.start_date,
      :where => self.resource_request.project.name,
      :all_day => true,
      :content => self.resource_request.comment
    })
    puts "GCal Save status: #{event.save}"
    puts "AR Save status: #{self.update_attributes( :event_id => event.id )}"
  end
  
  def update_event
    if self.event_id == 'caching'
      puts "Deferring event update"
      self.delay(:run_at => 2.minutes.from_now).update_event 
    else    
      puts "Starting update event for resource allocation #{self.id}"
      service = GCal4Ruby::Service.new
      auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
      puts "Authentication Status: #{auth}"
        
      event = GCal4Ruby::Event.find(service, {:id => self.event_id})
      puts "Event search result: #{event}"
    
      event.start_time = self.start_date
      event.end_time = self.start_date + 8.hours
      puts "GCal Save status: #{event.save}"
    end
  end
end
