# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :task do |f|
  f.name Faker::Lorem.sentence
end
