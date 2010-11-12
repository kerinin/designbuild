# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :deadline do |f|
  f.name Faker::Lorem.sentence
  f.date "2010-11-10"
  
  f.project {|p| p.association(:project)}
end
