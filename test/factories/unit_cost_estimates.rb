# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :unit_cost_estimate do |f|
  f.name {Forgery::DesignBuild.cost_name}
  f.unit_cost {Forgery::Monetary.money :min => 1, :max => 50}
  f.drop {rand(150)/10}
  
  f.quantity {|p| p.association(:quantity)}
end
