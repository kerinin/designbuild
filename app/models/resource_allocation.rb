class ResourceAllocation < ActiveRecord::Base
  attr_accessor :nested
  
  belongs_to :resource_request
  belongs_to :resource
  
  default_scope :order => :start_date
  
  validates_presence_of :start_date, :duration 
  validates_presence_of :resource_request, :unless => :nested
  
  after_create do |r|
    r.delay.create_event if r.event_id.nil?
  end
  #after_update :update_event
  after_save :update_request
  before_save :get_resource
  after_destroy :update_request
  before_destroy do |r|
    Delayed::Job.enqueue( DeleteEventJob.new(r.event_id) ) unless r.event_id.nil?
  end
  
  private
  
  def get_resource
    self.resource = self.resource_request.resource
  end
  
  def update_request
    self.resource_request.save!
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

=begin
class DeleteEventJob
  attr_accessor :cal_id
  
  def initialize(cal_id)
    self.cal_id = cal_id
  end
  
  def perform
    puts "Starting delete event for event #{self.cal_id}"
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication status: #{auth}"  
        
    event = GCal4Ruby::Event.find(service, {:id => self.cal_id})
    puts "Event search result: #{event}"
    
    puts "Event delete status: #{event.delete}"
  end    
end
=end