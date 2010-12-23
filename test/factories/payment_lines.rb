# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :payment_line do |f|
  f.comment { Forgery::LoremIpsum.text( :sentance ) if rand(3) }
  f.labor_paid { rand(100) }
  f.material_paid { rand(100) }
  f.labor_retained { rand(100) }
  f.material_retained { rand(100) }
  
  f.payment {|p| p.association(:payment)}
  f.cost {|p| p.association(:contract)}
end
