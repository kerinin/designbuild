# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :unit_cost_estimate do |f|
  f.name "MyString"
  f.unit_cost 1.5
  f.tax 1.5
end
