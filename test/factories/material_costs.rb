# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :material_cost do |f|
  f.date "2010-11-10"
  f.cost 20.0
  
  f.task {|p| p.association(:task)}
  # ???  Can materials be associated with components instead?
end
