# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :bid do |f|
  f.contractor {Forgery::Name.full_name}
  f.date {Forgery::Date.date}
  f.cost {Forgery::Monetary.money :min => 1000, :max => 10000}
  
  f.contract {|p| p.association(:contract)}
end
