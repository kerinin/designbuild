# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :quantity do |f|
  f.name {Forgery::LoremIpsum.sentence}
  f.value 1.5
  f.unit "sf"
  f.drop 1.5
  
  f.component {|p| p.association(:component)}
end
