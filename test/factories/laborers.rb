# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :laborer do |f|
  f.name {Forgery::Name.full_name}
  f.bill_rate 1.5
  
  f.project {|p| p.association(:project)}
end
