# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :quantity do |f|
  f.name "MyString"
  f.value 1.5
  f.unit "MyString"
  f.drop 1.5
end
