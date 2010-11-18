# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :quantity do |f|
  f.name {Forgery::DesignBuild.quantity_name}
  f.value {rand(1000)}
  f.unit {Forgery::DesignBuild.unit_name}
  
  f.component {|p| p.association(:component)}
end
