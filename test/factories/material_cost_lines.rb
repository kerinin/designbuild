# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :material_cost_line do |f|
  f.name Faker::Lorem.sentence
  f.quantity 1.5
  
  f.material_set {|p| p.association(:material_cost)}
end