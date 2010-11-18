# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :bid do |f|
  f.contractor {Forgery::Name.company_name}
  f.date {Forgery::Date.date :max_delta => 180}
  f.cost {Forgery::Monetary.money :min => 1000, :max => 10000}
  
  f.contract {|p| p.association(:contract)}
end
