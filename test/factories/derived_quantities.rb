# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :derived_quantity do |f|
  f.name Faker::Lorem.sentence
  f.multiplier 1.5
  
  f.parent_quantity {|p| p.association(:quantity )}
end
