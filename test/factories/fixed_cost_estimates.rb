# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :fixed_cost_estimate do |f|
  f.name Faker::Lorem.sentence
  f.cost 1.5
  
  f.component {|p| p.association(:component)}
end
