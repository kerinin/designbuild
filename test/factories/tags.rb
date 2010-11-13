# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :tag do |f|
  f.name {Forgery::LoremIpsum.word}
end
