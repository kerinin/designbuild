# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :invoice do |f|
  f.date {Forgery::Date.date :future => false, :max_delta => 180}
  f.state "start"
  
  f.project {|p| p.association(:project)}
end
