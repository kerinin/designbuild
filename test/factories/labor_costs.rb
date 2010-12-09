# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :labor_cost do |f|
  f.date {Forgery::Date.date :max_delta => 180}
  f.percent_complete {rand(100)}
  f.note {Forgery::LoremIpsum.text( :sentance ) if rand(2)}
  
  f.task {|p| p.association(:task)}
end
