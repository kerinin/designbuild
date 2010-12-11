# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :invoice_line do |f|
  # These should be generated from default procedures
  #f.labor_invoiced { rand(100) }
  #f.material_invoiced { rand(100) }
  
  #f.labor_retainage { rand(50) }
  #f.material_retainage { rand(50) }
  
  f.labor_paid { rand(100) }
  f.material_paid { rand(100) }
  
  f.labor_retained { rand(100) }
  f.material_retained { rand(100) }

  f.comment { Forgery::LoremIpsum.text( :sentance ) if rand(3) }
  
  f.invoice {|p| p.association(:invoice)}
  f.cost {|p| p.association(:contract)}
end
