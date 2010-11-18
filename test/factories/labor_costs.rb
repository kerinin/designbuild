# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :labor_cost do |f|
  f.date {Forgery::Date.date}
  f.percent_complete {rand(100)}
  
  f.task {|p| p.association(:task)}
end
