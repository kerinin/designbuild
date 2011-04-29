# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :payment_markup_line do |f|
  f.comment { Forgery::LoremIpsum.text( :sentance ) if rand(3) }
  
  f.payment {|p| p.association(:payment)}
  f.markup {|p| p.association(:markup)}
end
