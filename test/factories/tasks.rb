# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :task do |f|
  f.name {Forgery::LoremIpsum.sentence}
  
  f.project {|p| p.association(:project)}
end
