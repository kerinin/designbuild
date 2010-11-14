# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :relative_deadline do |f|
  f.name {Forgery::LoremIpsum.sentence}
  f.interval {rand(100) - 50}
  
  f.parent_deadline {|p| p.association(:deadline)}
end
