# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :unit_cost_estimate do |f|
  f.name Faker::Lorem.sentence
  f.unit_cost 1.5
  f.tax 0.0825
  
  f.quantity {|p| p.association(:quantity)}
  f.task {|p| p.association(:task)}
end
