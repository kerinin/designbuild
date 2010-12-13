# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :payment do |f|
  f.date {Forgery::Date.date :future => false, :max_delta => 180}
  f.paid { rand(100) }
  f.state "start"
  
  f.project {|p| p.association(:project)}
end
