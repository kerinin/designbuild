# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :derived_quantity do |f|
  f.name {Forgery::LoremIpsum.sentence :random => true}
  f.multiplier {rand(100).to_f/20}
  
  f.parent_quantity {|p| p.association(:quantity)}
end
