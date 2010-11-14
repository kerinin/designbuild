# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract_cost do |f|
  f.date {Forgery::Date.date}
  f.cost {Forgery::Monetary.money :min => 1000, :max => 10000}
  
  f.contract {|p| p.association(:contract)}
end
