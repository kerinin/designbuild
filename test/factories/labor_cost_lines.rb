# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :labor_cost_line do |f|
  f.hours 1.5
  
  f.task {|p| p.association(:labor_cost)}
end
