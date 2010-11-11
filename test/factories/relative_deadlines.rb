# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :relative_deadline do |f|
  f.name Faker::Lorem.sentence
  f.interval 1
  
  f.parent_deadline {|p| p.association(:deadline)}
end
