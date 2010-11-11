# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :unit_cost_estimate do |f|
  f.name Faker::Lorem.sentence
  f.unit_cost 1.5
  f.tax 0.0825
  
  f.component {|p| p.association(:component) }
  f.quantity {|p| p.association(:quantity)}
end
