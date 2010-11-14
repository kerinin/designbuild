# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :material_cost do |f|
  f.date {Forgery::Date.date}
  f.cost {Forgery::Monetary.money :min => 100, :max => 100000}
  
  f.task {|p| p.association(:task)}
  # ???  Can materials be associated with components instead?
end
