# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :derived_quantity do |f|
  f.name "MyString"
  f.multiplier 1.5
end
