module ApplicationHelper
  include AddOrNil
  
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
  
  def icon(name)
    image_tag "#{name}.png", :alt => name.to_s.capitalize, :size => "16x16"
  end
end
