class DeleteCalendarJob < Struct.new(:cal_id)  
  def perform
    puts "Starting delete calendar for calendar #{cal_id}"
    
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication status: #{auth}"
    
    cal = GCal4Ruby::Calendar.find(service, {:id => cal_id})
    puts "Calendar search result #{cal}"
    
    puts "Calendar delete status: #{cal.delete}"
  end
end

class DeleteEventJob < Struct.new(:event_id)  
  def perform
    puts "Starting delete event for event #{event_id}"
    service = GCal4Ruby::Service.new
    auth = service.authenticate(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_LOGIN'])
    puts "Authentication status: #{auth}"  
        
    event = GCal4Ruby::Event.find(service, {:id => event_id})
    puts "Event search result: #{event}"
    
    puts "Event delete status: #{event.delete}"
  end
end