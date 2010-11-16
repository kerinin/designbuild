# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :fixed_cost_estimate do |f|
  f.name {Forgery::DesignBuild.cost_name}
  f.cost {Forgery::Monetary.money :min => 100, :max => 1000}
  
  f.component {|p| p.association(:component)}
end
