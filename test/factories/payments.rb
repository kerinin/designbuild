# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :payment do |f|
  f.date "2010-12-13"
  f.paid 1.5
end
