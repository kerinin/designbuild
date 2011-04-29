# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :invoice_markup_line do |f|
  f.comment { Forgery::LoremIpsum.text( :sentance ) if rand(3) }
  
  f.invoice {|p| p.association(:invoice)}
  f.markup {|p| p.association(:markup)}
end
