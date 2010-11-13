# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :deadline do |f|
  f.name {Forgery::LoremIpsum.sentence :random => true}
  f.date {Forgery::Date.date :future => true, :max_delta => 365}
  
  f.project {|p| p.association(:project)}
end
