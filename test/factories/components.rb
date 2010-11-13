# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :component do |f|
  f.name {Forgery::LoremIpsum.sentence :random => true}
  
  f.project {|p| p.association(:project)}
end
