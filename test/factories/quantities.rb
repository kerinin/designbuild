# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :quantity do |f|
  f.name {Forgery::LoremIpsum.sentence}
  f.value {rand(1000)}
  f.unit "sf"
  f.drop 10
  
  f.component {|p| p.association(:component)}
end
