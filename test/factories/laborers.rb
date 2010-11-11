# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :laborer do |f|
  f.name Faker::Name.name
  f.pay_rate 1.5
end
