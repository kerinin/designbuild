# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :labor_cost_line do |f|
  f.hours {rand(8)}
  
  f.labor_set {|p| p.association(:labor_cost)}
  f.laborer {|p| p.association(:laborer)}
end
