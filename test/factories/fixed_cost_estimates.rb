# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :fixed_cost_estimate do |f|
  f.name {Forgery::LoremIpsum.sentence :random => true}
  f.cost {Forgery::Monetary.money :min => 100, :max => 1000}
  
  f.component {|p| p.association(:component)}
end
