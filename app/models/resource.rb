class Resource < ActiveRecord::Base
  has_many :resource_requests, :dependent => :destroy
  has_many :resource_allocations, :dependent => :destroy
  
  default_scope :order => :name
  
  validates_presence_of :name
  
  after_create do |r|
    r.delay.create_calendar if r.calendar_id.nil?
  end
  #before_save proc {|r| r.delay.create_calendar}, :if => proc {|r| r.calendar_id.nil?}
  before_destroy do |r|
    Delayed::Job.enqueue( DeleteCalendarJob.new(r.calendar_id) ) unless r.calendar_id.nil?
  end
  
  def create_calendar
    puts "Starting create calendar for resource id #{self.id}"
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication status: #{auth}"
    
    cal = GCal4Ruby::Calendar.new(service, {
      :title => "#{self.name} Schedule",
      :hidden => false
    })
    puts "GCal save status: #{cal.save}"
    puts "AR save status: #{self.update_attributes(:calendar_id => cal.id)}"
  end
end

class DeleteCalendarJob
  attr_accessor :cal_id
  
  def initialize(cal_id)
    self.cal_id = cal_id
  end
  
  def perform
    puts "Starting delete calendar for calendar #{self.cal_id}"
    
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication status: #{auth}"
    
    cal = GCal4Ruby::Calendar.find(service, {:id => cal_id})
    puts "Calendar search result #{cal}"
    
    puts "Calendar delete status: #{cal.delete}"
  end    
end