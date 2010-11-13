# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract do |f|
  f.contractor {Forgery::LoremIpsum.sentence :random => true}
  f.bid 1.5
  
  f.project {|p| p.association(:project)}
end
