# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :material_cost_line do |f|
  f.name {Forgery::DesignBuild.cost_name}
  f.quantity {rand(1000)}
  
  f.material_set {|p| p.association(:material_cost)}
end
