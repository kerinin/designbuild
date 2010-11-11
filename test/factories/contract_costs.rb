# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract_cost do |f|
  f.date "2010-11-10"
  f.amount 1.5
  
  f.contract {|p| p.association(:contract)}
end
