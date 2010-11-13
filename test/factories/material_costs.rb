# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :material_cost do |f|
  f.date {Forgery::Date.date}
  f.cost 20.0
  
  f.task {|p| p.association(:task)}
  # ???  Can materials be associated with components instead?
end
