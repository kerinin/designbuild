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
      "(#{date} days ago)"
    end
  end
end
