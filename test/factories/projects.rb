# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :project do |f|
  f.name {Forgery::LoremIpsum.sentence :random => true}
end
