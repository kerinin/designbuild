# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :payment_line do |f|
  f.labor_paid 1.5
  f.labor_retained 1.5
  f.material_paid 1.5
  f.material_retained 1.5
  f.comment "MyString"
end
