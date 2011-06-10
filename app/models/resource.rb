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
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    
    cal = GCal4Ruby::Calendar.new(service, {
      :title => "#{self.name} Schedule",
      :hidden => false
    })
    cal.save
    self.update_attributes(:calendar_id => cal.id)
  end
end

class DeleteCalendarJob
  attr_accessor :cal_id
  
  def initialize(cal_id)
    self.cal_id = cal_id
  end
  
  def perform
    service = GCal4Ruby::Service.new
    service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])

    cal = GCal4Ruby::Calendar.find(service, {:id => cal_id})
    cal.delete
  end    
end