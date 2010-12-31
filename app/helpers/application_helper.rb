module ApplicationHelper
  include AddOrNil
  
  def class_from_percent(percent)
    (0..100).step(20) {|i| return "percent_#{i}" if percent <= i}
  end
  
  def date_relative_to_now(date)
    delta = date - Date::today
    case
    when delta > 1
      "#{date - Date::today} days from now"
    when delta == 1
      "Tomorrow"
    when delta == 0
      "Today"
    when delta == -1
      "Yesterday"
    else
      "#{Date::today - date} days ago"
    end
  end
  
  def icon(name, size = "16x16")
    image_tag "#{name}.png", :alt => name.to_s.capitalize, :size => size
  end
  
  def weekday(day, week_date)
    day = case day
    when :sun, :sunday
      7
    when :mon, :monday
      1
    when :tue, :tuesday
      2
    when :wed, :wednesday
      3
    when :thur, :thursday, :thu
      4
    when :fri, :friday
      5
    when :sat, :saturday
      6
    else
      day
    end
    
    offset = day - week_date.cwday
    week_date + offset
  end
end
